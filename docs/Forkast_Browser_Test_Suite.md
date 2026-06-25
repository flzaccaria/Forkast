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

## 7. Eliminazione

| ID | Pri | Passi | Atteso | Previene |
| --- | --- | --- | --- | --- |
| BT-60 | 🟡 | Elimina un piatto (cestino nell'editor) → osserva l'altro device | Sparisce live su entrambi | propagazione delete |
| BT-61 | 🟡 | Elimina un piatto che è in un piano | Avviso "usato in N cene" prima di procedere; poi la Lista mostra "Aggiorna" | delete protetta / FR-21 |

## 8. Specifici web (bassa priorità)

| ID | Pri | Passi | Atteso |
| --- | --- | --- | --- |
| BT-70 | ⚪ | Modifica dati, poi F5 | I dati persistono al reload |
| BT-71 | ⚪ | Due tab aperte, modifiche in entrambe | Nessuna perdita dati |
| BT-72 | ⚪ | "Aggiungi a Home" (iPhone/Android), apri da lì | A tutto schermo, barra/titolo corretti |

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
