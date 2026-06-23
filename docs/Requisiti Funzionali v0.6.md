# App Menu Settimanale & Lista della Spesa — Requisiti Funzionali

*Versione 0.6 • 23 giugno 2026 • Bozza per validazione*

> **Nota di riconciliazione.** Questa versione unisce i miglioramenti decisi nel brainstorming (fase "miglioramenti") sulla baseline del repo v0.5. Dove la v0.5 aveva già introdotto una funzionalità (reparto e ordinamento della lista per corsie, FR-22; "copia settimana" su settimana non vuota, FR-19), si è adottata la versione del repo. Dove una scelta è presa di proposito ma resta reversibile, è marcata **[Decisione]**.

## Novità in questa versione (v0.6)

- **Unità di misura come insieme chiuso definito nel codice** (enum), non più "unità predefinita" generica: mette in sicurezza l'aggregazione (FR-5).
- **Gestione ingredienti** promossa a tab di navigazione (fuori da Impostazioni), con raggruppamento per reparto e ordinamento per individuare i doppioni; sfrutta il campo reparto introdotto in v0.5 (nuovo **FR-23**).
- **Difficoltà e tempo** come campi strutturati a scelta singola, in sostituzione degli attributi a vocabolario libero. La portata resta invariata (FR-14, FR-15). **[Decisione]**
- **Rigenerazione della lista automatica e invisibile** di default: cadono l'avviso di aggiornamento e l'opzione nelle impostazioni. Lo strato manuale (spunte, voci a mano, override) continua a sopravvivere (FR-21).
- **Piano settimanale** mostra i nomi reali dei piatti per ciascun giorno, non un conteggio (FR-7).
- L'**arrotondamento** è esplicitato come interno, invisibile e deterministico (§6).

## Novità in v0.5

- Ordinamento della lista della spesa per reparto del supermercato: requisito **FR-22**, regola di ordinamento in §6, punto aperto §8 risolto.

## Novità in v0.4

- "Copia settimana precedente" su una settimana non vuota: l'utente sceglie tra **sostituisci** e **aggiungi** (FR-19 aggiornato, punto aperto §8 risolto).

## Novità in v0.3

- Introduzione dei tag dei piatti — portata e attributi — e dei filtri del catalogo.
- Scorciatoia "Copia la settimana precedente" e giorno di inizio settimana configurabile.
- Definizione del comportamento di override e rigenerazione della lista.
- Nuova sezione "Impostazioni".
- Regole di gestione del catalogo ingredienti: unità bloccata dopo l'uso, eliminazione protetta, unione dei doppioni.
- La portata di un piatto è facoltativa.

## 1. Contesto e obiettivo

Ogni settimana la coppia deve decidere il menu delle cene della settimana successiva e, di conseguenza, preparare la lista della spesa. Oggi questo avviene senza strumenti dedicati, con il rischio di acquisti doppi, dimenticanze e sprechi.

L'obiettivo dell'app è collegare in modo automatico tre momenti: la definizione dei piatti, la loro pianificazione sui giorni della settimana e la generazione della lista della spesa, con le quantità degli ingredienti proporzionate al numero di commensali di ogni cena.

## 2. Utenti e ambito

Questa prima versione è a uso privato e familiare, pensata per l'utilizzo simultaneo da più dispositivi (sincronizzazione tra telefoni e accesso via web).

> Sono volutamente rimandati a fasi successive: pen-test e hardening di sicurezza, documentazione privacy/GDPR, scelte di pricing e pubblicazione sugli store, oltre alla gestione formale di account, inviti e condivisione tra utenti. Le decisioni architetturali odierne verranno prese in modo da non precludere queste evoluzioni.

## 3. Concetti principali

Il sistema ruota attorno a cinque concetti collegati:

| Concetto | Descrizione |
| --- | --- |
| **Piatto** | Ricetta riutilizzabile nel tempo. Definisce un insieme di ingredienti con quantità in base 4 persone. Può avere una portata (facoltativa) e, facoltativi, una difficoltà e un tempo. |
| **Ingrediente** | Voce di un catalogo condiviso, a livello di prodotto (es. "pomodori freschi" e "pomodori a pezzi in barattolo" sono voci distinte). Ogni voce ha una sola unità di misura (da insieme chiuso) e un reparto facoltativo. |
| **Portata** | Etichetta di classificazione del piatto: una sola, facoltativa, da vocabolario curato gestito nelle impostazioni. |
| **Piano settimanale** | Associazione di uno o più piatti a un giorno (solo cene), con il numero di commensali per quella serata. |
| **Lista della spesa** | Elenco derivato e aggregato, generato automaticamente dal piano settimanale, su due strati (generato + manuale), raggruppato per reparto. |

## 4. Requisiti funzionali

### 4.1 Gestione dei piatti

| ID | Requisito |
| --- | --- |
| **FR-1** | L'utente può creare, modificare ed eliminare piatti in un catalogo riutilizzabile settimana dopo settimana. |
| **FR-2** | Le quantità degli ingredienti di un piatto sono espresse in base 4 persone. |
| **FR-3** | Ogni piatto può contenere più ingredienti, ciascuno scelto dal catalogo condiviso degli ingredienti. |
| **FR-14** | A ogni piatto si possono assegnare: una **portata** (scelta singola, facoltativa, da vocabolario curato nelle impostazioni); una **difficoltà** (facoltativa, scelta singola tra *facile · medio · difficile*); un **tempo** (facoltativo, scelta singola tra *veloce · medio · lento*). Difficoltà e tempo sono scale ordinate. **[Decisione]** Sostituiscono gli attributi a vocabolario libero della v0.5; una dimensione di etichettatura libera (es. dietetica) potrà essere reintrodotta in futuro come campo separato. |
| **FR-15** | Il catalogo dei piatti è ricercabile per nome e filtrabile per portata, difficoltà e tempo. Con cataloghi ampi (50+ piatti) la ricerca è il mezzo primario di accesso. |

### 4.2 Catalogo degli ingredienti

| ID | Requisito |
| --- | --- |
| **FR-4** | Gli ingredienti vivono in un catalogo condiviso, così che lo stesso ingrediente usato in piatti diversi sia la medesima voce e possa essere aggregato. |
| **FR-5** | Ogni ingrediente ha una sola unità di misura, scelta da un **insieme chiuso definito nel codice** (enum); non è testo libero. Prodotti con unità diverse sono voci di catalogo diverse. Nessuna conversione tra unità. |
| **FR-6** | Un ingrediente può essere marcato come "quanto basta": comparirà nella lista senza quantità e non verrà riscalato (es. sale, olio, spezie). |
| **FR-16** | L'unità di misura di un ingrediente non è modificabile dopo che la voce è stata usata in almeno un piatto: cambiarla renderebbe incoerenti le somme della lista. |
| **FR-17** | Un ingrediente usato in uno o più piatti non è eliminabile finché non viene rimosso da quei piatti. La schermata mostra dove è usato. |
| **FR-18** | Due voci doppione del catalogo possono essere unite, a condizione che abbiano la stessa unità di misura. |
| **FR-22** | La lista della spesa è raggruppata e ordinata per **reparto** del supermercato, seguendo l'ordine del percorso tipico nel negozio. Ogni ingrediente ha un campo reparto facoltativo, scelto da un elenco fisso predefinito (Ortofrutta, Macelleria, Pescheria, Salumi e formaggi, Latticini e uova, Pane e forno, Dispensa, Surgelati, Bevande, Cura della casa, Cura della persona, Altro). Gli ingredienti il cui reparto non è stato assegnato (`null`) compaiono in coda sotto l'intestazione "Senza reparto". "Altro" è un reparto selezionabile dall'utente per ingredienti che non rientrano nelle altre categorie; "Senza reparto" indica invece che l'utente non ha ancora assegnato alcun reparto. All'interno di ogni reparto gli ingredienti sono ordinati per nome. |
| **FR-23** | La **gestione ingredienti** è una sezione principale dell'app (tab di navigazione, non più sotto Impostazioni). Elenca gli ingredienti **raggruppati per reparto** (FR-22, inclusa l'intestazione "Senza reparto") e permette di **ordinarli** (es. per nome) per individuare e unire i doppioni. Restano valide FR-16, FR-17, FR-18. |

### 4.3 Pianificazione settimanale

| ID | Requisito |
| --- | --- |
| **FR-7** | L'utente assegna uno o più piatti a ciascun giorno della settimana (solo cene). Il piano **mostra i nomi dei piatti** assegnati a ciascun giorno, non un conteggio. |
| **FR-8** | Il numero di commensali ha un valore predefinito globale, configurabile nelle impostazioni dell'app. Quando si pianifica una cena, questo valore viene proposto automaticamente e può essere sovrascritto per la singola serata. Il valore è a livello di serata e vale per tutti i piatti di quella cena. |
| **FR-9** | Lo stesso piatto può essere assegnato a giorni diversi con numeri di commensali diversi. |
| **FR-19** | L'utente può copiare i piatti e i commensali della settimana precedente nella settimana corrente. Se la settimana corrente non è vuota, l'app chiede se **sostituire** (cancella il piano esistente e lo rimpiazza con la copia) o **aggiungere** (accoda i piatti copiati a quelli già presenti, giorno per giorno). La lista della spesa non viene copiata: si rigenera dal piano. |
| **FR-20** | Il giorno di inizio settimana (lunedì o domenica) è configurabile nelle impostazioni. |

### 4.4 Lista della spesa

| ID | Requisito |
| --- | --- |
| **FR-10** | La lista della spesa è generata automaticamente a partire dal piano settimanale. |
| **FR-11** | Le quantità sono riscalate dalla base 4 al numero di commensali effettivo di ogni cena (es. 6 commensali → × 1,5), esclusi gli ingredienti "quanto basta". |
| **FR-12** | Gli ingredienti identici provenienti da piatti diversi sono aggregati sommando le quantità in un'unica riga. La somma è sempre coerente perché una stessa voce di catalogo ha un'unica unità. |
| **FR-13** | L'utente può effettuare un override manuale della lista: aggiungere, modificare o rimuovere righe a mano. |
| **FR-21** | La lista è organizzata su **due strati**. Le righe generate dal piano si **rigenerano automaticamente** quando il piano cambia, **senza intervento né avviso** all'utente. Le aggiunte manuali, le spunte di acquisto e gli override a righe generate **persistono** alla rigenerazione. Un override resta **reversibile**: un comando "ripristina" riporta la riga al valore calcolato. *(Rispetto alla v0.5 cadono l'avviso di aggiornamento e l'opzione di rigenerazione manuale.)* |

## 5. Impostazioni

L'app espone alcune impostazioni globali:

- **Commensali predefiniti**: valore globale proposto a ogni nuova cena (FR-8).
- **Inizio settimana**: lunedì o domenica (FR-20).
- **Promemoria settimanale di pianificazione**: opzionale.
- **Vocabolario delle portate**: gestione del vocabolario curato delle portate (FR-14).
- **Aspetto e lingua**: tema (sistema/chiaro/scuro) e lingua dell'app.
- **Sincronizzazione**: stato della sincronizzazione tra dispositivi. La gestione di account, inviti e condivisione è rimandata (vedi §2).

*(Rispetto alla v0.5: rimossa l'opzione "rigenerazione automatica" — ora è il comportamento di default e invisibile, FR-21. La gestione degli ingredienti esce da qui e diventa un tab, FR-23.)*

## 6. Regole di calcolo

- **Riscalo**: quantità finale = quantità base 4 × (commensali ÷ 4). Si applica a tutti gli ingredienti tranne quelli "quanto basta".
- **Aggregazione**: gli ingredienti vengono raggruppati per voce di catalogo; le quantità riscalate vengono sommate. L'unità da enum (FR-5) garantisce che voci "uguali" coincidano davvero.
- **Quanto basta**: l'ingrediente compare nella lista una sola volta, senza quantità, indipendentemente dal numero di piatti o commensali.
- **Ordinamento per reparto**: le voci della lista sono raggruppate per reparto del supermercato nell'ordine del percorso in negozio. Gli ingredienti senza reparto assegnato (`category = null`) compaiono in coda, dopo tutti i reparti e dopo "Altro". All'interno di ogni gruppo l'ordinamento è alfabetico per nome.
- **Arrotondamento**: regola unica, deterministica, isolata in un modulo testato. È **interno e invisibile**: l'utente non vede né configura arrotondamenti, e i risultati sono sempre "da supermercato" (interi sui pezzi, tagli sensati sui pesi). Essendo deterministico, un ricalcolo su dispositivi diversi converge allo stesso risultato (presupposto della rigenerazione automatica, FR-21).

## 7. Esempio concreto

Piatto "Hamburger", base 4 persone: 4 panini, 600 g di carne macinata, 1 insalata, 4 pomodori freschi, sale q.b.

Lunedì → Hamburger per 6 persone. Mercoledì → Insalata mista per 2 persone (2 pomodori freschi in base 4, quindi 1 per 2 persone).

Lista risultante per i pomodori freschi: 6 (da hamburger) + 1 (da insalata) = 7 pomodori freschi in un'unica riga. Il sale comparirà come "q.b." senza quantità. Le righe compaiono sotto il reparto di appartenenza.

## 8. Punti aperti (da definire in fase di design)

- Rimozione di una **portata** in uso: proteggerla (come per gli ingredienti) oppure offrire uno "scollega dai piatti".
- Obbligatorietà della portata: la proposta attuale è di lasciarla facoltativa.
- Crescita del **vocabolario delle portate**: mantenerlo curato oppure consentire aggiunte libere.
- Eventuale reintroduzione di una dimensione di **etichettatura libera** (es. dietetica), oggi rimossa con gli attributi (FR-14).
- Insieme iniziale delle **unità** (enum): definire il set di partenza nel codice e se/come renderlo estensibile in futuro.

*Risolti nelle versioni precedenti:* comportamento override/rigenerazione (FR-21); ordinamento per reparto (FR-22, v0.5); "copia settimana" su settimana non vuota (FR-19, v0.4).

## 9. Fuori ambito (per ora)

- Colazioni e pranzi (solo cene in questa versione).
- Gestione della dispensa / "ce l'ho già in casa" (gestibile temporaneamente via override manuale).
- Suggerimenti nutrizionali o bilanciamento dei pasti.
- Sicurezza formale, privacy/GDPR, pricing e pubblicazione sugli store.
- Gestione formale di account, inviti e condivisione tra utenti.

---

*Requisiti Funzionali v0.6*
