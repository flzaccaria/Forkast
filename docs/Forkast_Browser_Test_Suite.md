# Forkast — Browser Test Suite (E2E manuale)

**Checklist di regressione per la web app deployata.** Non gira in `flutter test`: copre infrastruttura, sync,
RLS, reattività e localizzazione — cose verificabili solo dal vivo. Tienila in repo e aggiornala a ogni feature.

_v1.0 · giugno 2026 · URL: https://forkast.flzaccaria.workers.dev/_

---

## Come si usa (protocollo — leggere sempre)

1. **Sempre in una finestra INCOGNITO NUOVA.** Lo store locale PowerSync (IndexedDB) si trascina stati vecchi
   tra i deploy: un profilo "sporco" maschera i bug del primo sync e ti fa testare la coda avvelenata di ieri.
   L'incognito = device nuovo, ogni volta.
2. **Apri DevTools → Network PRIMA di caricare**, con **Preserve log** attivo. Filtra su Fetch/XHR.
3. **Esegui lo SMOKE SET dopo OGNI deploy.** Il resto della suite quando tocchi quell'area.
4. Per ogni FAIL, annota status/messaggio esatto dalla Network o cosa vedi a schermo. Non "non va": il `code`/`message`.

### Il "freshness gate" — verifica che stai testando il deploy giusto

Prima di dare colpa al codice, conferma che il browser serve la build nuova:

- **Console:** `crossOriginIsolated` → deve essere `true`. Se `false`, stai su build/SW vecchio → Application →
  Service Workers → Unregister + Storage → Clear site data (o incognito).
- **Header dal server** (PowerShell, bypassa la cache con un URL random):
  ```powershell
  (Invoke-WebRequest "https://forkast.flzaccaria.workers.dev/?nocache=$(Get-Random)" -Method Head -UseBasicParsing).Headers
  ```
  Devono comparire `Cross-Origin-Opener-Policy: same-origin` e `Cross-Origin-Embedder-Policy: credentialless`.

---

## 🔴 SMOKE SET — da rieseguire a OGNI deploy (~5 min)

| ID | Check | Atteso | Previene (bug storico) |
| --- | --- | --- | --- |
| **SM-1** | Header COOP/COEP nella response (comando sopra) | Entrambi presenti | header persi → DB non parte |
| **SM-2** | Console: `crossOriginIsolated` | `true` | SW/build vecchio servito |
| **SM-3** | `powersync_db.worker.js` in Network | 200, non resta "pending" all'infinito | worker che non si avvia |
| **SM-4** | Apri il catalogo Ingredienti | Si popola, niente spinner eterno | store stantio / DB non init |
| **SM-5** | Crea un ingrediente → guarda Supabase tabella `ingredient` | La riga compare entro ~30s | coda upload bloccata |
| **SM-6** | Network durante il primo sync: POST `/rest/v1/ingredient` | Status 201, **zero 400** | 23502 rounding_kind, RLS 403 |
| **SM-7** | Crea un piatto | Compare nel catalogo entro ~2s **senza refresh** | reattività stream rotta |
| **SM-8** | Ingrediente usato in un piatto → prova a eliminarlo | Eliminazione bloccata (snackbar) | FR-17 delete protetta |
| **SM-9** | Ingrediente usato in un piatto → apri modifica | Dropdown unità disabilitato | FR-16 unità bloccata |
| **SM-10** | Copia settimana precedente su vuota → Lista | Piatti copiati + Lista si rigenera | FR-19 copia settimana |
| **SM-11** | Cambia ospiti 4→6 → Lista | Quantità riscalate senza refresh | ospiti → riscalo reattivo |
| **SM-12** | Apri l'app → tab attivo | Il tab attivo è **Piano** (non Ingredienti) | default landing tab (v0.7) |

Se SM-1/2/3/4 falliscono: è **infrastruttura**, fermati e sistema quella prima di testare le feature.

---

## 1. Infrastruttura & primo sync

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-01 | 🔴 | Incognito nuovo → carica l'app | bootstrap: `auth/v1/signup` → `rpc/bootstrap_household` → seed | bootstrap household |
| BT-02 | 🔴 | Network: cerca `POST /rest/v1/household` | **Non deve esistere** (l'household lo crea l'RPC) | insert locale household → 403 |
| BT-03 | 🔴 | Network: POST su `/rest/v1/ingredient` durante il seed | Status 201, **nessun 400/403** | 23502, RLS recursion 42P17 |
| BT-04 | 🟡 | Conta le POST di upload del seed | **Poche** richieste (upsert in blocco), non ~190 | upload riga-per-riga lento |
| BT-05 | 🟡 | Crea un ingrediente, controlla Supabase `ingredient` | Riga presente entro ~30s | coda bloccata da op fatale |

## 2. Reattività (stesso dispositivo, MAI fare refresh)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-10 | 🔴 | Crea un piatto | Compare nel catalogo Piatti entro ~2s | watch() che non riemette |
| BT-11 | 🔴 | Aggiungi un piatto al piano → vai su Lista | La lista si aggiorna da sola entro ~2s | rigenerazione non reattiva |
| BT-12 | 🟡 | Override/spunta su una riga della Lista | Cambio visibile subito, persiste | stream Lista incompleto |
| BT-13 | 🔴 | Cambia lingua (Impostazioni) | Etichette UI **e** nomi seed cambiano subito | rebuild su locale mancante |

## 3. Calcolo (l'oracolo)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-20 | 🔴 | Hamburger (4 pomodori pz, 600g carne, sale q.b.) per 6 + Insalata (2 pomodori) per 2 | pomodori **7 pz** in una riga, carne **900 g**, sale q.b. senza qty | riscalo/aggregazione |
| BT-21 | 🟡 | uovo (1, Pezzo intero) per 6 | **2 uova** (1×1,5 → ↑ intero), non 1,5 | allowlist arrotondamento |
| BT-22 | 🟡 | patate (1 kg, Peso) per 5 | **1,3 kg** (↑ 0,1), con la **virgola** non il punto | granularità + separatore IT |
| BT-23 | 🟡 | latte (500 ml, Volume) per 3 | **380 ml** (375 → ↑ 10) | granularità volume |

## 4. Lista a due strati (FR-21)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-30 | 🟡 | Aggiungi una voce manuale | Persiste come riga additiva separata | strato manuale |
| BT-31 | 🟡 | Override quantità di una riga generata, poi "ripristina" | Override persiste; ripristino torna al calcolo | reversibilità override |
| BT-32 | 🟡 | Spunta voci, poi cambia il piano | Lista si rigenera; spunte e voci manuali sopravvivono | rigenerazione invisibile |

## 5. Localizzazione seed

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-40 | 🔴 | Cambia lingua IT→EN→DA, guarda i **nomi** seed nel catalogo | Cambiano (es. Aglio→Garlic→Hvidløg) | anello seed_key→locale mancante |
| BT-41 | 🟡 | Stessa cosa nelle **righe della Lista** della spesa | Nomi tradotti anche lì | traduzione non applicata ovunque |
| BT-42 | 🟡 | Stessa cosa nel **selettore ingredienti** dell'editor piatti | Nomi tradotti anche lì | idem |
| BT-43 | 🟡 | Un ingrediente creato a mano (no seed_key) | Resta invariato in tutte le lingue | name_modified / fallback |

## 6. Pairing & sync multi-dispositivo (due sessioni)

> Serve un **secondo dispositivo o una seconda sessione separata** (telefono, o secondo profilo/incognito). Due tab
> normali condividono identità e store, quindi NON valgono come "due dispositivi".

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-50 | 🔴 | Device A: genera codice di abbinamento | 6 cifre + countdown + immagine QR, niente 400/403 | create_pairing_code, household 403 |
| BT-51 | 🟡 | Inquadra il QR col telefono | Apre la PWA con il campo codice precompilato (non ricerca Google) | APP_URL nel build |
| BT-52 | 🟡 | Dopo l'abbinamento, fai refresh sul telefono | Resta sull'app, **non** torna ad "Abbina"; URL senza `?code=` | replaceState deep-link |
| BT-53 | 🔴 | Device B inserisce il codice → si unisce | B vede **solo** i dati di A (niente set vuoto "suo" in più) | doppio household |
| BT-54 | 🔴 | Modifica su A → osserva B (e viceversa), senza refresh | Si propaga entro pochi secondi nei due sensi | bridge sync / coda |

## 7. Eliminazione e protezioni (FR-16/17)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-60 | 🟡 | Elimina un piatto (cestino nell'editor) → osserva l'altro device | Sparisce live su entrambi | propagazione delete |
| BT-61 | 🟡 | Elimina un piatto che è in un piano | Avviso "usato in N cene" prima di procedere; poi la Lista mostra "Aggiorna" | delete protetta / FR-21 |
| BT-62 | 🔴 | Crea un piatto con un ingrediente → vai in Ingredienti → prova a eliminare quell'ingrediente | Snackbar "Usato in N piatti", eliminazione bloccata | FR-17 delete protetta ingrediente |
| BT-63 | 🟡 | Stesso ingrediente → tap "Dove è usato" | Mostra la lista dei piatti che lo usano | FR-17 info uso |
| BT-64 | 🟡 | Crea una portata, assegnala a un piatto → prova a eliminarla | Snackbar "Usato in N piatti", eliminazione bloccata | FR-14 tag protetti |
| BT-65 | 🟡 | Elimina una portata **non** usata in nessun piatto | Si elimina con successo | falso positivo su tag deletion |

## 8. Specifici web (bassa priorità)

| ID | Pri | Passi | Atteso |
| --- | --- | --- | --- |
| BT-70 | ⚪ | Modifica dati, poi F5 | I dati persistono al reload |
| BT-71 | ⚪ | Due tab aperte, modifiche in entrambe | Nessuna perdita dati |
| BT-72 | ⚪ | "Aggiungi a Home" (iPhone/Android), apri da lì | A tutto schermo, barra/titolo corretti |

## 9. Ingredienti — vincoli e gestione (FR-16/18)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-80 | 🔴 | Crea un ingrediente (es. "Farina", g) → usalo in un piatto → torna in Ingredienti → apri la modifica | Il dropdown **unità** e il toggle **q.b.** sono disabilitati; helper text "unità bloccata" | FR-16 unità bloccata |
| BT-81 | 🟡 | Crea un ingrediente **non** usato in nessun piatto → apri la modifica | Dropdown unità e toggle q.b. restano **abilitati** | falso positivo su unit lock |
| BT-82 | 🟡 | Crea due ingredienti con la stessa unità (es. "Pomodoro A" pz, "Pomodoro B" pz), usa entrambi in un piatto → unisci A in B | Merge riuscito: A sparisce, B ha le quantità sommate nel piatto | FR-18 merge duplicati |
| BT-83 | 🟡 | Crea due ingredienti con unità **diverse** (es. "Latte" ml, "Latte" pz) → prova a unire | Merge bloccato: snackbar "le unità devono coincidere" | FR-18 guard merge |

## 10. Catalogo piatti — filtri (FR-14/15)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-90 | 🟡 | Crea un piatto con difficoltà "Facile" e tempo "Veloce", un altro con "Difficile" e "Lento" | Entrambi visibili nel catalogo con i badge corretti | difficoltà/tempo non salvati |
| BT-91 | 🟡 | Nella barra filtri, seleziona difficoltà "Difficile" | Solo il piatto "Difficile" resta visibile | filtro difficoltà rotto |
| BT-92 | 🟡 | Seleziona tempo "Veloce" | Solo il piatto "Veloce" resta visibile | filtro tempo rotto |
| BT-93 | 🟡 | Assegna una portata (es. "Primo") a un piatto → filtra per quella portata | Solo i piatti con quella portata restano visibili | filtro portata rotto |
| BT-94 | 🟡 | Combina due filtri (portata + difficoltà) | Intersezione: solo i piatti che soddisfano entrambi | filtri combinati |

## 11. Piano settimanale — navigazione, ospiti, copia (FR-19/20)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-100 | 🟡 | Piano → freccia destra | Intestazione mostra la settimana successiva (numero ISO + date) | navigazione settimane |
| BT-101 | 🟡 | Vai avanti di 3 settimane → tap "Oggi" | Torna alla settimana corrente | pulsante Oggi |
| BT-102 | 🔴 | Pianifica 2 cene nella settimana corrente → vai alla settimana dopo (vuota) → "Copia settimana precedente" | I piatti e il numero ospiti compaiono nella nuova settimana; la Lista si aggiorna | FR-19 copia su vuoto |
| BT-103 | 🟡 | Pianifica un piatto anche nella settimana di destinazione → "Copia settimana precedente" | Dialog chiede "Aggiungi" o "Sostituisci"; scegli Aggiungi → i piatti si sommano | FR-19 copia su non-vuoto |
| BT-104 | 🔴 | Apri un giorno del piano → cambia ospiti da 4 a 6 → vai su Lista | Le quantità si riscalano (es. 600 g → 900 g per 6 ospiti) **senza refresh** | UI ospiti → riscalo reattivo |
| BT-105 | 🟡 | Stesso di BT-104, poi rimetti ospiti a 4 | Le quantità tornano ai valori base | riscalo bidirezionale |

## 12. Navigazione e atterraggio (FR-23 v0.7)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-120 | 🔴 | Apri l'app in incognito (primo avvio) | Il tab attivo è **Piano**, non Ingredienti | A: default landing su tab sbagliato |
| BT-121 | 🟡 | Osserva l'ordine dei tab nella barra di navigazione | Ingredienti · Piatti · Piano · Lista (da sinistra) | A: ordine tab invertito |

## 13. Link ricetta sul piatto (FR-14/P9)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-130 | 🟡 | Crea un piatto con un URL ricetta (es. `https://example.com/ricetta`) → salva → riaprilo | Il campo "Link alla ricetta" mostra l'URL salvato | C: recipe_url non persistito |
| BT-131 | 🟡 | Piatto con URL → tap sull'icona di apertura | Si apre il browser esterno con l'URL | C: url_launcher non funziona |
| BT-132 | 🟡 | Crea un piatto **senza** URL ricetta | Il campo resta vuoto, nessuna icona di apertura | C: campo obbligatorio per errore |

## 14. Autocomplete ingredienti nell'editor piatto (D3)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-140 | 🟡 | Nell'editor piatto, tap "Aggiungi" ingrediente → digita "pomo" | La lista filtra mostrando solo ingredienti con "pomo" nel nome | D3: filtro non attivo |
| BT-141 | 🟡 | Digita "pomodroi" (typo) → tap "Crea nuovo ingrediente" | Dialog avviso "Ingredienti simili: Pomodori" → l'utente può annullare o creare comunque | D3: anti-doppioni assente |
| BT-142 | 🟡 | Seleziona un ingrediente esistente dal catalogo | La riga eredita unità/q.b. dal catalogo; non viene creata una nuova voce | D3: selezione crea duplicato |

## 15. Reparti e raggruppamento (FR-22/23)

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-110 | 🟡 | Crea 3 ingredienti in reparti diversi (Ortofrutta, Carne, Dispensa) | Reparto visibile nella scheda ingrediente | reparto non salvato |
| BT-111 | 🟡 | In Ingredienti, attiva "Raggruppa per reparto" | Le voci si raggruppano con intestazioni sticky per reparto, nell'ordine del percorso del supermercato | raggruppamento reparti |
| BT-112 | 🟡 | Usa gli ingredienti in un piatto → vai alla Lista della spesa | Le righe sono raggruppate per reparto, stessa sequenza dei reparti | raggruppamento lista |
| BT-113 | 🟡 | Crea un ingrediente **senza** reparto | Appare sotto "Senza reparto" (o in fondo alla lista) | fallback reparto null |

---

## Manutenzione (importante)

Questa suite è **viva**: ogni feature o fix che tocca un'area qui sotto deve aggiungere/aggiornare un caso BT.

**Convenzione per ogni nuovo caso:**
- ID progressivo `BT-NN` nella sezione giusta.
- Colonna **"Previene"**: il bug/feature che il caso protegge (così non viene cancellato per sbaglio e si capisce perché esiste).
- Priorità: 🔴 = entra nello SMOKE SET (regressione critica, ogni deploy) · 🟡 = standard · ⚪ = opzionale.

**Da incollare nel `CLAUDE.md` del repo**, così l'agente la tiene aggiornata da solo:

```
Esiste una browser test suite manuale in docs/Forkast_Browser_Test_Suite.md per i comportamenti verificabili solo dal
vivo (infrastruttura, header COOP/COEP, sync PowerSync, RLS, reattività degli stream, localizzazione, pairing
multi-dispositivo). Regola: quando scrivi codice che tocca una di queste aree — schema/migration, powersync_connector,
bootstrap, RLS/policy, bridge db.updates, rigenerazione lista, localizzazione, deploy/wrangler/header — aggiungi o
aggiorna il caso BT corrispondente in quel file, con la colonna "Previene" che cita il bug/feature. Se il cambiamento
introduce una regressione critica, marca il caso 🔴 (smoke set). Non rimuovere casi BT senza motivo esplicito.
```

## Storico esecuzioni (compila a ogni giro)

| Data | Build / Version ID | Smoke | Note / fail |
| --- | --- | --- | --- |
| | | | |
