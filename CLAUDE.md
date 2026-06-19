# CLAUDE.md — App Menu Settimanale & Lista della Spesa

> File di contesto per Claude Code. Letto a ogni sessione. Mantienilo conciso e aggiornato.
> Fonti di verità complete: `Requisiti_Funzionali_v0.3.docx`, `Mappa_Flussi_e_Schermate_v1.0.docx`, `ADR_Architettura_v1.0.docx`.
> Se una richiesta contraddice questo file o un ADR, **fermati e segnalalo** invece di decidere in autonomia.

---

## Cos'è il progetto

App mobile (iPhone + Android) per una coppia/famiglia: pianificare il menu delle **cene** della settimana e generare la **lista della spesa** con le quantità proporzionate ai commensali.

Ambito di questa fase: uso privato e familiare, **solo cene**, **due dispositivi**. Niente web. Account, inviti e condivisione formale sono rimandati ma l'architettura non deve precluderli.

---

## Vincolo guida (non negoziabile)

L'app si usa **al supermercato, offline**. Deve essere **local-first**: leggere/scrivere sempre sul database locale (istantaneo) e sincronizzare in background quando c'è rete. Mai bloccare la UI in attesa del server.

---

## Stack tecnico

| Livello | Scelta | Note |
| --- | --- | --- |
| Client | **Flutter** + **drift** (SQLite locale) | Codebase unico iOS/Android. Web escluso. |
| Backend | **Supabase** (Postgres), **region EU** | Relazionale: serve all'integrità del catalogo. |
| Sync | **PowerSync** | Replica Postgres ↔ SQLite locale; coda di upload offline. |
| Auth (fase 1) | Supabase **anonymous sign-in** per dispositivo | Nessun account/email ora. |

Setup iniziale obbligatorio (ADR-002, ADR-008):
- Creare il progetto Supabase in **region EU** dal giorno zero.
- Configurare il WAL per progetti piccoli (es. `max_wal_size` più basso) per evitare il gonfiamento del disco su istanze inattive.

---

## Principi architetturali (gli ADR in pillole)

1. **Local-first** (ADR-001). SQLite sul dispositivo = fonte di verità per la UI. Il backend è hub di sync e archivio durevole, non intermediario di ogni lettura.
2. **Sincronizza gli input, deriva gli output** (ADR-004). NON sincronizzare ciò che è calcolabile. La lista generata è funzione di (piano + piatti + catalogo).
3. **Conflitti: semplici** (ADR-003). Last-write-wins per campo + **UUID generati dal client** su ogni insert + flag idempotenti. **Niente CRDT.**
4. **Household come aggregate root** (ADR-005). Ogni entità porta un `household_id`. È anche la chiave del bucket di sync PowerSync e il futuro confine di autorizzazione.
5. **Privacy by design** (ADR-008). Data minimization, nessuna analytics con dati personali, dati in EU.

---

## Modello dati (spina dorsale)

Ogni tabella porta `household_id`. Ogni insert usa un **UUID generato dal client**.

- `household` — contenitore di tutti i dati.
- `membership` — lega un dispositivo (domani un utente) a un household. Base del pairing.
- `ingredient` — catalogo condiviso. Possiede `unit` e il flag `is_qb` ("quanto basta").
- `tag` — gruppo `portata` (singola) o `attributo` (multiplo), con colore e ordine.
- `dish` + `dish_tag` — piatto riutilizzabile; una portata, più attributi.
- `dish_ingredient` — riga ingrediente del piatto, `qty_base4` (ignorata per gli `is_qb`).
- `week_plan` → `plan_day` (con `commensali` della serata) → `plan_day_dish`.
- `shopping_list` — contesto snapshot: settimana, `generated_at`, **impronta/hash del piano d'origine**.
- `list_generated_row` — riga derivata dello snapshot (ingrediente, qty riscalata, unità).
- `list_override` — modifica reversibile di una riga generata, agganciata all'`ingredient_id`.
- `list_manual_item` — voce aggiunta a mano (ID proprio), additiva e persistente.
- `list_check` — spunta idempotente per (lista, ingrediente); persiste tra rigenerazioni.

---

## Invarianti e regole da rispettare nel codice

- **Quantità in base 4** (FR-2). I piatti definiscono le quantità per 4 persone.
- **Riscalo** (FR-11): `qty_finale = qty_base4 × (commensali ÷ 4)`, escluso `is_qb`.
- **Aggregazione** (FR-12): somma per voce di catalogo; coerente perché una voce ha un'unica unità.
- **Regola di arrotondamento UNICA**, in un **modulo condiviso e testato** (§5 ADR). Es. prodotti a pezzo intero → arrotonda per eccesso. Deve essere deterministica.
- **Unità bloccata** (FR-16): non modificabile dopo che l'ingrediente è usato in ≥1 piatto. Enforcement **nella UI** (l'azione vietata non è nemmeno mostrata) + riconciliazione in sync.
- **Eliminazione protetta** (FR-17): ingrediente in uso non eliminabile; mostrare dove è usato.
- **Unione doppioni** (FR-18): solo a parità di unità.
- **Lista a due strati** (FR-21): generato (snapshot ricreabile) + manuale/override/spunte (persistenti). Override reversibile via "ripristina".
- **Rigenerazione NON automatica di default** (FR-21): quando il piano diverge dall'impronta salvata sullo snapshot, mostrare l'avviso "Aggiorna"; l'utente decide quando. Opzione per la rigenerazione automatica nelle impostazioni.

> Nota offline-first: le invarianti cross-device sono **best-effort** (UI + riconciliazione), non transazioni globali. È un limite accettato (§6 ADR). Non promettere garanzie transazionali tra dispositivi.

---

## Da fare / da NON fare

**FAI**
- Scrivi sempre prima in locale, poi lascia sincronizzare PowerSync.
- Filtra ogni query per `household_id`; imposta le regole di accesso (RLS) di conseguenza.
- Isola riscalo + arrotondamento in un modulo puro e testato.
- Genera lo snapshot lista su azione esplicita dell'utente, salvando l'hash del piano.

**NON FARE**
- Niente CRDT / Automerge / Yjs.
- Non sincronizzare le righe generate come se fossero dati primari: derivale.
- Non legare i dati al singolo dispositivo: sempre all'household.
- Niente analytics con dati personali; nessuna email/PII in questa fase.
- Non introdurre un client web (ribalterebbe la scelta Flutter).

---

## Pairing dei dispositivi (l'unico "auth-lite" da costruire ora) — FATTO

Il secondo telefono entra nell'household del primo via **codice numerico a 6 cifre generato dal primo**, con identità anonima per dispositivo + riga di `membership`. Domani l'identità anonima si promuove ad account reale (email) senza ristrutturare nulla (ADR-006).

Implementazione:
- Funzioni Postgres `SECURITY DEFINER` (`supabase/migrations/00002_pairing.sql`): `create_pairing_code()` e `redeem_pairing_code(p_code)`. Incapsulano l'unica scrittura privilegiata che le RLS bloccherebbero (un device che non è ancora membro). `pairing_code` resta server-side, esclusa da PowerSync.
- Modello join: il secondo telefono **adotta l'household di chi invita** e abbandona il proprio (vuoto) del bootstrap; bloccato se ha già dati propri.
- Client: `lib/data/pairing_service.dart` (wrapper `rpc()`), `PairingScreen` (mostra/inserisci codice), `householdId` commutabile a runtime via `AppScope.onHouseholdChanged`.
- **Email predisposta**: seam documentato in `PairingService` per innestare l'invito-via-email quando l'identità anonima diventerà account reale, senza ristrutturare.
- QR-scan: scartato di proposito (due telefoni vicini, digitare 6 cifre è più rapido).

---

## Punti aperti (segnalare, non decidere da soli)

- Ordinamento lista per reparto: richiede un attributo `category` su `ingredient`, oggi assente.
- Obbligatorietà della portata: attualmente facoltativa.
### Risolti
- "Copia settimana precedente" su settimana non vuota (FR-19): l'utente sceglie **sostituisci o aggiungi** al momento della copia.
- Rimozione di un tag in uso (FR-14): **protetta** (bloccata se in uso, mostra il conteggio), coerente con FR-17.
- Autenticazione JWT legacy: guida alla migrazione HS256→ES256/JWKS in `docs/auth_jwt_migration.md`. Solo configurazione dashboard, nessuna modifica al codice.

---

## Comandi (da completare a setup avvenuto)

```bash
flutter pub get          # dipendenze
flutter run              # avvio in debug su device/emulatore
flutter test             # test (includere i test della regola di riscalo/arrotondamento)
flutter analyze          # lint statico
```
