# Architecture Decision Record (ADR) — App Menu Settimanale & Lista della Spesa

*v1.0 • 17 giugno 2026 • Architettura della fase*

| | |
| --- | --- |
| **Documento** | Architecture Decision Record — architettura della fase iniziale |
| **Stato** | Decisioni accettate (validate con il committente) |
| **Autore** | Software & Data Architect |
| **Documenti correlati** | Requisiti Funzionali v0.3 • Mappa dei flussi e delle schermate v1.0 |
| **Ambito** | Prima versione a uso privato e familiare — solo cene, due dispositivi |

## 1. Scopo e contesto

Questo documento registra le decisioni architetturali della prima fase dell'app. Accompagna i Requisiti Funzionali v0.3 (cosa l'app deve fare) e la Mappa dei flussi v1.0 (dove e come ci si muove): qui si stabilisce su quali fondamenta tecniche poggia tutto il resto.

La decisione madre è dove vivono i dati e come si sincronizzano tra i telefoni: tutte le altre scelte discendono da lì. Il vincolo guida è l'uso reale dell'app: la lista della spesa si consulta e si modifica al supermercato, dove la connessione è inaffidabile. L'app deve quindi funzionare offline e risincronizzare in seguito.

Tre obiettivi di lungo periodo orientano le scelte pur senza essere implementati ora, perché oggi costano quasi nulla ed evitano una riscrittura domani: modellare il concetto di famiglia/household come contenitore dei dati; predisporre l'autenticazione; raccogliere il minimo indispensabile di dati personali (privacy by design).

## 2. Sintesi delle decisioni

| ID | Tema | Decisione | Req. |
| --- | --- | --- | --- |
| **ADR-001** | Modello dei dati | Local-first: SQLite sul dispositivo come fonte di verità | FR-10–13, 21 |
| **ADR-002** | Backend e sync | Supabase (Postgres, region EU) + PowerSync | FR-4, 12, 16–18 |
| **ADR-003** | Conflitti | Last-write-wins + UUID lato client + idempotenza (no CRDT) | FR-13, 21 |
| **ADR-004** | Lista della spesa | Snapshot materializzato + strato override/spunte per ingrediente | FR-10–13, 21 |
| **ADR-005** | Contenitore dati | Household come aggregate root su ogni entità | §2 requisiti |
| **ADR-006** | Identità e pairing | Accesso anonimo per device + codice/QR di abbinamento | §2 requisiti |
| **ADR-007** | Stack client | Cross-platform: Flutter + drift (SQLite) | — |
| **ADR-008** | Privacy e residenza | Data minimization + dati in region EU dal giorno zero | §2 requisiti |

## 3. Decisioni architetturali

### ADR-001 — Modello dei dati: local-first

**Stato:** Accettata • **Requisiti correlati:** FR-10, 11, 12, 13, 21

**Contesto.** La lista della spesa si usa al supermercato, dove la connessione è intermittente. Il modello "cloud-first" (l'app interroga sempre il server e tiene una cache come ripiego) trasforma il funzionamento offline in un'aggiunta posticcia, con i sintomi classici: interfaccia bloccata in attesa del server, oppure modifiche perse alla risincronizzazione.

**Opzioni valutate.**

- **Cloud-first con cache** — Semplice da avviare ma fragile offline; le scritture offline diventano un caso speciale da gestire a mano.
- **Local-first** — Il database vive sul dispositivo; l'app legge e scrive sempre in locale (istantaneo), un layer di sync replica verso il backend quando c'è rete.
- **Peer-to-peer puro tra i due telefoni** — Niente backend, ma i due telefoni sono raramente online insieme e manca un punto durevole di archiviazione: inaffidabile.

**Decisione.** Architettura local-first. Su ogni dispositivo un database SQLite è la fonte di verità per l'interfaccia. Il backend fa da hub di sincronizzazione e archivio durevole, non da intermediario obbligatorio di ogni lettura.

**Conseguenze.**

- *Vantaggio:* l'app è sempre reattiva e pienamente utilizzabile offline; la sincronizzazione è un processo di fondo.
- *Vantaggio:* la generazione e la consultazione della lista non dipendono dalla rete.
- *Costo:* si rinuncia alla consistenza forte e immediata tra i due dispositivi: è il compromesso strutturale dell'offline-first (vedi ADR-003 e §6).

### ADR-002 — Backend e motore di sincronizzazione

**Stato:** Accettata • **Requisiti correlati:** FR-4, 5, 12, 16, 17, 18

**Contesto.** Servono un archivio durevole e un meccanismo di sync robusto. Due famiglie tecnologiche: archivio a documenti (NoSQL, es. Firebase/Firestore) oppure relazionale (Postgres). I requisiti del catalogo — ingrediente condiviso come voce unica, aggregazione per voce, unità bloccata dopo l'uso, eliminazione protetta — sono tutta integrità referenziale, terreno nativo del relazionale.

**Opzioni valutate.**

- **Firebase / Firestore** — Offline integrato e avvio rapidissimo, ma modello a documenti: l'integrità del catalogo va riscritta a mano e diventa un peso crescente.
- **Supabase (Postgres) + PowerSync** — Postgres relazionale (adatto al modello) con autenticazione e regole di accesso, più un layer di sync maturo che replica verso un SQLite locale su ogni client.
- **ElectricSQL / Triplit e simili** — Promettenti ma rischiosi oggi: feedback di produzione molto polarizzati per il primo; il secondo è passato a manutenzione della community dopo un'acquisizione. Scartati per continuità.

**Decisione.** Supabase (Postgres) come backend, in region EU, con PowerSync come layer di sincronizzazione. PowerSync replica il Postgres verso un database SQLite locale su ogni dispositivo, con regole di sync che determinano quali dati arrivano a chi; le scritture locali finiscono in una coda di upload inviata appena c'è connessione. PowerSync è oggi la scelta matura quando la correttezza del sync è un requisito e non un di più; ha SDK di prima classe per Flutter, e si può anche self-hostare in futuro per ridurre la dipendenza dal fornitore.

**Conseguenze.**

- *Vantaggio:* modello relazionale che rispetta i vincoli del catalogo senza acrobazie; autenticazione e regole d'accesso già disponibili per la porta "auth" (ADR-006).
- *Costo:* un certo lock-in sul modello di sync: è il prezzo per non scrivere un motore di sync proprio, ampiamente conveniente per questo progetto.
- *Nota:* PowerSync usa la logical replication di Postgres; su Supabase va impostata una configurazione del WAL (es. `max_wal_size` più basso) per i progetti piccoli, altrimenti le istanze inattive gonfiano il disco. È una riga di configurazione, da fare in avvio.

### ADR-003 — Strategia di risoluzione dei conflitti

**Stato:** Accettata • **Requisiti correlati:** FR-13, 21

**Contesto.** Con l'offline-first due telefoni possono modificare la stessa cosa mentre sono scollegati. Serve una regola di riconciliazione, decisa ora almeno come principio. Va però calibrata sull'uso reale: due sole persone in una famiglia, con una superficie di conflitto minuscola.

**Opzioni valutate.**

- **CRDT (es. Automerge/Yjs)** — Fusione automatica robusta anche con molti editori concorrenti, ma complessità ingiustificata per due utenti: over-engineering.
- **Last-write-wins (LWW) per campo** — L'ultima scrittura vince a livello di singolo campo. Semplice e più che sufficiente quando le modifiche concorrenti reali sono rarissime.
- **Merge server-autoritativo custom** — Possibile con PowerSync, ma non necessario in questa fase.

**Decisione.** Principio in tre mosse, senza alcun motore CRDT:

1. Last-write-wins per campo sulla maggior parte delle entità.
2. Identificatori (UUID) generati dal client su ogni inserimento, così che due aggiunte concorrenti (piatti, voci manuali della lista) non collidano mai — sono prive di conflitto per costruzione.
3. Le spunte di acquisto sono booleani idempotenti per coppia (lista, ingrediente): "spuntato" raramente viene annullato in concorrenza, e LWW basta.

**Conseguenze.**

- *Vantaggio:* modello semplice, prevedibile e adeguato alla scala reale; nessuna libreria di fusione da mantenere.
- *Nota:* il modello dati va comunque tenuto "friendly": ID stabili e niente strutture che richiedano fusione posizionale. Se un domani servisse il riordino manuale di liste condivise, si userà l'indicizzazione frazionaria.

### ADR-004 — Lista della spesa: snapshot materializzato a due strati

**Stato:** Accettata • **Requisiti correlati:** FR-10, 11, 12, 13, 21

**Contesto.** La lista generata è funzione del piano (riscalo dei piatti dalla base 4 al numero di commensali, aggregazione per voce di catalogo). La tentazione è trattarla come un'altra tabella da sincronizzare con tutti i suoi conflitti. Ma FR-21 stabilisce che la rigenerazione, di default, NON è automatica: quando il piano cambia, l'app segnala e l'utente decide quando aggiornare. Questo cambia la natura dello strato generato: non è una derivazione ricalcolata a ogni apertura, ma uno snapshot prodotto da un'azione esplicita dell'utente su un dispositivo.

**Opzioni valutate.**

- **Derivare a ogni render (non sincronizzare il generato)** — Minimizza lo stato sincronizzato, ma confligge con FR-21 (rigenerazione manuale) e richiede arrotondamenti identici su entrambi i dispositivi a ogni calcolo.
- **Snapshot materializzato sincronizzato + strato override/spunte separato** — Lo strato generato è uno stato persistente prodotto su richiesta; override e spunte vivono in uno strato a parte, agganciato alla voce di catalogo.

**Decisione.** Lista a due strati. Strato generato: snapshot materializzato che porta con sé un'impronta (hash/versione) del piano da cui è nato; quando il piano corrente diverge dall'impronta, l'app mostra l'avviso "Aggiorna" — è l'implementazione pulita e gratuita del segnale di FR-21. Strato manuale e override: voci aggiunte a mano (con ID proprio) e modifiche/spunte agganciate all'`ingredient_id`; sopravvivono alla rigenerazione (lo snapshot si butta e si ricrea, override e spunte restano). Poiché a generare lo snapshot è sempre un solo dispositivo per volta, il problema dell'arrotondamento divergente tra telefoni non si pone (vedi anche §5).

**Conseguenze.**

- *Vantaggio:* mappa 1:1 sui requisiti: realizza la "lista a due strati", l'override reversibile e l'avviso di rigenerazione senza acrobazie.
- *Vantaggio:* riduce lo stato realmente sincronizzato ed elimina una classe intera di conflitti.

### ADR-005 — Household come aggregate root

**Stato:** Accettata • **Requisiti correlati:** Ambito §2 dei requisiti

**Contesto.** Oggi la famiglia è una sola e non c'è login. Se i dati venissero legati al singolo dispositivo, introdurre domani il multi-utente sarebbe una riscrittura. Il costo di prevenirlo ora è quasi nullo.

**Opzioni valutate.**

- **Dati legati al device** — Più immediato, ma chiude la porta al multi-utente futuro.
- **Dati legati a un household** — Ogni entità porta un `household_id`; domani basta aggiungere account e inviti.

**Decisione.** Modellare il concetto di household (famiglia) come contenitore: ogni entità — piatto, ingrediente, tag, piano, lista — porta un `household_id`, anche con un unico household in questa fase. In PowerSync l'`household_id` diventa la chiave del "bucket" di sincronizzazione, cioè esattamente il confine che domani sarà di autorizzazione.

**Conseguenze.**

- *Vantaggio:* un solo concetto serve due scopi: scoping del sync oggi, confine di sicurezza domani.
- *Costo:* trascurabile: una colonna in più sulle tabelle e una disciplina di query da rispettare fin dall'inizio.

### ADR-006 — Identità e abbinamento dei dispositivi

**Stato:** Accettata • **Requisiti correlati:** Ambito §2 dei requisiti

**Contesto.** I requisiti rimandano account, inviti e condivisione, ma chiedono l'uso simultaneo da più dispositivi. Sono in tensione: sincronizzare due telefoni è già una forma minima di condivisione e richiede che il secondo telefono sappia entrare nell'household del primo. Questo pezzo non è rimandabile — è l'unico bit di "auth-lite" da costruire ora.

**Opzioni valutate.**

- **Tutto aperto, nessuna identità** — Presuppone che chiunque acceda a tutto: chiude la porta all'auth e va contro la privacy by design.
- **Account completi subito** — Fuori ambito per questa fase e non richiesto.
- **Accesso anonimo per device + abbinamento via codice/QR** — Ogni dispositivo riceve un'identità anonima, legata a un household tramite una riga di membership; il secondo telefono entra scansionando un codice generato dal primo.

**Decisione.** Accesso anonimo per dispositivo (anonymous sign-in), dispositivi legati a un household tramite una riga di membership, e ingresso del secondo telefono tramite codice/QR di abbinamento generato dal primo. Nessun account, nessuna email in questa fase. Domani l'identità anonima si "promuove" a un account reale con email senza ristrutturare nulla: è letteralmente la porta dell'autenticazione che si apre da sola.

**Conseguenze.**

- *Vantaggio:* il backend non presuppone mai "chiunque vede tutto"; le regole d'accesso filtrano già per household.
- *Nota:* va progettato ora un piccolo flusso di abbinamento (genera codice / scansiona codice): è il minimo indispensabile non rimandabile.

### ADR-007 — Stack del client: cross-platform Flutter

**Stato:** Accettata • **Requisiti correlati:** —

**Contesto.** L'app deve girare su iPhone e Android, sviluppata da un team molto piccolo. Il web è esplicitamente fuori dai piani. Tra le scelte architetturali è quella a impatto più basso: il motore di sync conta molto più del framework.

**Opzioni valutate.**

- **Nativo iOS + Android** — Due codebase per due persone: insostenibile e ingiustificato.
- **Flutter + drift (SQLite)** — Codebase unico, integrazione PowerSync molto rodata (nata su Flutter), coerenza dell'interfaccia su entrambe le piattaforme.
- **React Native + WatermelonDB** — Valido; il suo vantaggio principale (riuso della logica in un futuro client web in TypeScript) non si incassa perché il web è escluso.

**Decisione.** Flutter con drift (SQLite locale) come stack del client. La scelta di escludere il web rende superfluo il principale motivo che avrebbe fatto preferire React Native, e l'integrazione Flutter–PowerSync è la più matura.

**Conseguenze.**

- *Vantaggio:* un solo codebase, interfaccia coerente, percorso di sincronizzazione ben supportato.
- *Nota:* se in futuro il web tornasse in agenda, andrebbe rivalutato: è l'unico fattore che ribalterebbe questa decisione.

### ADR-008 — Privacy by design e residenza dei dati

**Stato:** Accettata • **Requisiti correlati:** Ambito §2 dei requisiti

**Contesto.** Raccogliere solo ciò che serve rende il GDPR di domani una formalità invece che un cantiere. I dati dell'app (piatti, ingredienti, piani, liste) non sono dati personali sensibili; l'unico dato personale sarà, in futuro, un'email.

**Opzioni valutate.**

- **Raccolta ampia + analytics con dati personali** — Comodo per il prodotto, ma crea un debito privacy da smaltire più avanti.
- **Minimizzazione + residenza EU dal giorno zero** — Si raccoglie il minimo; il progetto backend viene creato in region europea fin dall'inizio.

**Decisione.** Data minimization: nessuna analytics con dati personali; in questa fase l'unico identificatore è un'identità anonima del dispositivo. Creare il progetto Supabase in region EU dal giorno zero.

**Conseguenze.**

- *Vantaggio:* la residenza dei dati è una scelta di configurazione fatta ora; spostarla dopo sarebbe un cantiere. Il GDPR futuro parte già in regola.

## 4. Modello dati — la spina dorsale

Le entità portanti (non ogni colonna; il dettaglio spetta al disegno con Business Analyst e UX). Ogni entità porta un `household_id` (ADR-005).

| Entità | Descrizione | Req. |
| --- | --- | --- |
| `household` | Contenitore di tutti i dati. Oggi unico; domani estensibile a account e inviti. | §2 req. |
| `membership` | Lega un dispositivo (e domani un utente) a un household. Base dell'abbinamento. | ADR-006 |
| `ingredient` | Voce del catalogo condiviso. Possiede l'unità di misura e il flag "quanto basta". | FR-4, 5, 6 |
| `tag` | Etichetta dei piatti. Gruppo portata (singola) o attributo (multiplo), con colore e ordine. | FR-14 |
| `dish` + `dish_tag` | Piatto riutilizzabile; collegamento ai tag (una portata, più attributi). | FR-1, 14 |
| `dish_ingredient` | Riga ingrediente di un piatto, con quantità in base 4 (ignorata per i "quanto basta"). | FR-2, 3 |
| `week_plan` → `plan_day` → `plan_day_dish` | Settimana → giorno (con numero di commensali della serata) → piatti assegnati. | FR-7, 8, 9, 20 |
| `shopping_list` | Contesto dello snapshot: settimana, momento di generazione, impronta del piano d'origine. | FR-10, 21 |
| `list_generated_row` | Riga derivata dello snapshot (ingrediente, quantità riscalata, unità). | FR-11, 12 |
| `list_override` | Modifica reversibile di una riga generata, agganciata all'ingrediente. | FR-13, 21 |
| `list_manual_item` | Voce aggiunta a mano (ID proprio), additiva e persistente. | FR-13, 21 |
| `list_check` | Spunta di acquisto idempotente per (lista, ingrediente); persiste tra rigenerazioni. | FR-21 |

**Nota sull'unità bloccata e l'eliminazione protetta (FR-16, 17, 18):** sono invarianti applicate nell'interfaccia del client (l'utente non vede nemmeno l'azione vietata) e riconciliate in sincronizzazione. In un mondo offline-first non si può garantire al 100% un'invariante al momento della scrittura su dispositivi diversi: è il limite accettato del §6.

## 5. Regola di calcolo deterministica

Il riscalo (FR-11) moltiplica le quantità base 4 per (commensali ÷ 4), esclusi gli ingredienti "quanto basta". L'aggregazione (FR-12) somma le quantità riscalate per voce di catalogo, sempre coerenti perché una voce ha un'unica unità.

Va definita una sola regola di arrotondamento, in codice condiviso e testato. Esempio: 600 g × 1,5 = 900 g è immediato; 1 insalata × 1,5 richiede una scelta (arrotondare per eccesso sui prodotti a pezzo intero è il comportamento atteso al supermercato). Poiché lo snapshot è generato da un solo dispositivo (ADR-004), la regola unica garantisce risultati riproducibili senza divergenze tra telefoni.

## 6. Limiti noti e conseguenze accettate

- **Consistenza eventuale, non immediata:** tra i due dispositivi i dati convergono dopo la sincronizzazione, non istantaneamente. È il compromesso strutturale dell'offline-first (ADR-001) e per due utenti è ampiamente accettabile.
- **Invarianti cross-device best-effort:** unità bloccata ed eliminazione protetta sono garantite nell'interfaccia e riconciliate in sync, non come transazione globale tra dispositivi. La finestra di conflitto è minima e nella pratica l'utente non la incontra.
- **Lock-in sul layer di sync:** scegliere PowerSync significa dipendere dal suo modello; mitigato dalla possibilità di self-hosting e dal grande risparmio rispetto a scrivere un motore proprio.
- **Abbinamento dei dispositivi da costruire ora:** è il minimo "auth-lite" non rimandabile (ADR-006).

## 7. Punti aperti che intersecano l'architettura

- **Ordinamento della lista per reparto:** richiederebbe una categoria sugli ingredienti, oggi assente. È un nuovo attributo su `ingredient`, a basso costo se previsto ora nel modello.
- **"Copia settimana precedente" su una settimana non vuota:** definire se sostituire, unire o bloccare. È una scelta di comportamento sui dati del piano (FR-19).
- **Rimozione di un tag in uso:** proteggere oppure "scollega dai piatti". Analoga all'eliminazione protetta degli ingredienti (FR-17), va resa coerente con essa.
- **Rigenerazione automatica della lista:** l'opzione esiste (FR-21); quando attiva, l'arrotondamento deterministico del §5 diventa indispensabile perché il ricalcolo può avvenire su entrambi i dispositivi.

## 8. Prossimi passi

- Creare il progetto Supabase in region EU e configurare il WAL per progetti piccoli (ADR-002, ADR-008).
- Definire lo schema Postgres con `household_id` su ogni tabella e le regole di sync per bucket household (ADR-002, ADR-005).
- Implementare il flusso di abbinamento dispositivi (genera/scansiona codice) con accesso anonimo (ADR-006).
- Inizializzare il progetto Flutter con drift e l'SDK PowerSync; isolare la regola di riscalo/arrotondamento in un modulo testato (ADR-007, §5).
