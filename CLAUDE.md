# CLAUDE.md — Weekly Menu & Shopping List App

> Context file for Claude Code. Read at every session. Keep it concise and up to date.
> Complete sources of truth: `docs/Requisiti Funzionali v0.6.md`, `Mappa_Flussi_e_Schermate_v1.1.docx`, `ADR_Architettura_v1.1.docx`.
> If a request contradicts this file or an ADR, **stop and flag it** instead of deciding on your own.

---

## What the project is

An app (iPhone, Android, Web) for a couple/family: plan the week's **dinner** menu and generate the **shopping list** with quantities proportional to the number of guests.

Scope of this phase: private, family use, **dinners only**, **two devices + web**. Accounts, invites, and formal sharing are deferred, but the architecture must not preclude them.

---

## Guiding constraint (non-negotiable)

The app is used **at the supermarket, offline**. It must be **local-first**: always read/write to the local database (instant) and sync in the background when there is network. Never block the UI waiting for the server.

---

## Tech stack

| Layer | Choice | Notes |
| --- | --- | --- |
| Client | **Flutter** + **drift** (local SQLite) | iOS, Android, Web (Cloudflare Workers). |
| Backend | **Supabase** (Postgres), **EU region** | Relational: needed for catalog integrity. |
| Sync | **PowerSync** | Replicates Postgres ↔ local SQLite; offline upload queue. |
| Auth (phase 1) | Supabase **anonymous sign-in** per device | No account/email for now. |

Mandatory initial setup (ADR-002, ADR-008):
- Create the Supabase project in the **EU region** from day zero.
- Configure the WAL for small projects (e.g. lower `max_wal_size`) to avoid disk bloat on idle instances.

---

## Architectural principles (the ADRs in a nutshell)

1. **Local-first** (ADR-001). SQLite on the device = source of truth for the UI. The backend is a sync hub and durable archive, not an intermediary for every read.
2. **Sync the inputs, derive the outputs** (ADR-004). Do NOT sync what is computable. The generated list is a function of (plan + dishes + catalog).
3. **Conflicts: simple** (ADR-003). Last-write-wins per field + **client-generated UUIDs** on every insert + idempotent flags. **No CRDT.**
4. **Household as the aggregate root** (ADR-005). Every entity carries a `household_id`. It is also the key of the PowerSync sync bucket and the future authorization boundary.
5. **Privacy by design** (ADR-008). Data minimization, no analytics with personal data, data in the EU.

---

## Data model (the backbone)

Every table carries a `household_id`. Every insert uses a **client-generated UUID**.

- `household` — container for all data.
- `membership` — links a device (tomorrow a user) to a household. Basis for pairing.
- `ingredient` — shared catalog. Owns `unit` (from closed enum, FR-5) and the `is_qb` flag ("to taste").
- `tag` — `portata` (course, single) group, with color and order. Old `attributo` tags archived in DB (v0.6).
- `dish` + `dish_tag` — reusable dish; one course. Has optional `difficulty` and `time_estimate` fields (v0.6).
- `dish_ingredient` — ingredient row of the dish, `qty_base4` (ignored for `is_qb`).
- `week_plan` → `plan_day` (with the evening's `guests`) → `plan_day_dish`.
- `shopping_list` — snapshot context: week, `generated_at`, **fingerprint/hash of the source plan**.
- `list_generated_row` — derived snapshot row (ingredient, rescaled qty, unit).
- `list_override` — reversible modification of a generated row, tied to the `ingredient_id`.
- `list_manual_item` — manually added item (own ID), additive and persistent.
- `list_check` — idempotent check for (list, ingredient); persists across regenerations.

---

## Invariants and rules to respect in the code

- **Quantities in base 4** (FR-2). Dishes define quantities for 4 people.
- **Rescaling** (FR-11): `qty_finale = qty_base4 × (commensali ÷ 4)`, excluding `is_qb`.
- **Aggregation** (FR-12): sum per catalog item; consistent because an item has a single unit.
- **A SINGLE rounding rule**, in a **shared and tested module** (§5 ADR). E.g. whole-piece products → round up. It must be deterministic.
- **Unit locked** (FR-16): not editable once the ingredient is used in ≥1 dish. Enforced **in the UI** (the forbidden action isn't even shown) + reconciliation in sync.
- **Protected deletion** (FR-17): an ingredient in use cannot be deleted; show where it is used.
- **Merging duplicates** (FR-18): only when units match.
- **Two-layer list** (FR-21): generated (recreatable snapshot) + manual/override/checks (persistent). Override reversible via "restore".
- **Regeneration automatic and invisible** (FR-21 v0.6): when the plan diverges from the saved fingerprint, the generated layer regenerates silently. No banner, no user action, no setting. Manual layer (checks, overrides, manual items) persists.

> Offline-first note: cross-device invariants are **best-effort** (UI + reconciliation), not global transactions. This is an accepted limitation (§6 ADR). Do not promise transactional guarantees across devices.

---

## Do / DON'T

**DO**
- Always write locally first, then let PowerSync sync.
- Filter every query by `household_id`; set the access rules (RLS) accordingly.
- Isolate rescaling + rounding in a pure, tested module.
- The list snapshot regenerates automatically when the plan changes (v0.6).

**DON'T**
- No CRDT / Automerge / Yjs.
- Don't sync the generated rows as if they were primary data: derive them.
- Don't tie data to a single device: always to the household.
- No analytics with personal data; no email/PII in this phase.
- Web target is supported. Database opening uses conditional imports (`open_database_native.dart` / `open_database_web.dart`) to avoid `dart:ffi` on the web.

---

## PowerSync → drift notification bridge (fragile, do not remove)

`AppDatabase._listenPowerSyncUpdates` (`lib/data/database.dart`) subscribes to `PowerSyncDatabase.updates` and calls `notifyUpdates()` on the drift database for every sync-down change. This bridge is **required** for real-time UI updates across devices: without it, drift `.watch()` streams do not re-fire when another device's changes arrive via PowerSync sync, because those writes happen in a separate SQLite isolate whose update notifications may not reach drift's `StreamQueryStore` through `SqliteAsyncDriftConnection` alone.

If this subscription is removed or broken, the UI will appear to sync (data arrives in SQLite) but will **not refresh** until the user manually navigates away and back.

**Table name mapping**: PowerSync stores data in internal tables prefixed `ps_data__` (e.g. `ps_data__ingredient`). The SDK strips this prefix before emitting update events (see the `D2` helper in `web/powersync_db.worker.js`), so the names arriving at the bridge are already the logical/friendly ones (e.g. `ingredient`). The bridge filters them against `allTables` to avoid notifying for internal PowerSync tables that have no drift counterpart. If PowerSync ever changes this stripping behavior, the bridge will silently stop matching — watch for it.

---

## PowerSync upload connector — per-op error handling

`SupabaseConnector` (`lib/data/powersync_connector.dart`) flushes PowerSync's upload queue to Supabase. The `processCrudBatch` helper iterates each `CrudEntry` individually and classifies errors:

- **Fatal / permanent** (`isFatalUploadError`): Postgres class 22 (data exception), class 23 (integrity constraint), `42501` (insufficient privilege / RLS denial), HTTP `401`/`403`. These are **logged and skipped** — retrying would block the entire queue forever.
- **Transient**: any other `PostgrestException` rethrows immediately; PowerSync will retry the batch.

This per-op approach is critical: without it, a single RLS-rejected stale write (e.g. a household row the device no longer owns) would jam the queue and block all subsequent operations.

---

## RLS recursion fix — `auth_household_ids()` (migration `00006`)

The original RLS policies in `00001` used inline sub-selects on `membership` (e.g. `household_id IN (SELECT household_id FROM membership WHERE device_id = auth.uid())`). On the `membership` table itself this caused **infinite recursion** (Postgres error `42P17`), which silently broke cross-device sync — it had never worked before this fix.

Migration `00006` introduces `auth_household_ids()`, a `SECURITY DEFINER` function that reads `membership` bypassing RLS, and rewrites every table's policies to call it. The function is `STABLE` and granted only to `authenticated`.

---

## Household bootstrap & device pairing — DONE

Both operations use server-side `SECURITY DEFINER` functions because RLS blocks a device that is not yet a member from writing to `household`/`membership` (chicken-and-egg). See `docs/bootstrap_household.md` for the full rationale.

### Bootstrap (first launch)
- Postgres function `bootstrap_household()` (`supabase/migrations/00007_bootstrap_household_membership.sql`): creates `household` + `membership` atomically for `auth.uid()`, idempotent.
- Client: `lib/data/bootstrap.dart` → `ensureHousehold(db, deviceId)` checks the local DB first (offline-fast path); if no membership is found, calls `rpc('bootstrap_household')`. The rows arrive on the device via PowerSync sync (read, not write).
- Offline fallback: if the RPC fails for network, `BootstrapException` is thrown; the app shows an error screen and retries on next restart. The first launch always requires network (anonymous sign-in).

### Pairing (second device)
- Postgres functions `create_pairing_code()` and `redeem_pairing_code(p_code)` (`supabase/migrations/00002_pairing.sql`): encapsulate the only other privileged writes. `pairing_code` stays server-side, excluded from PowerSync.
- Join model: the second phone **adopts the inviter's household** and abandons its own (empty) bootstrap one; blocked if it already has its own data.
- Client: `lib/data/pairing_service.dart` (`rpc()` wrapper), `PairingScreen` (show code + QR / enter code), `householdId` switchable at runtime via `AppScope.onHouseholdChanged`.
- **QR payload**: `https://<APP_URL>?code=123456` (compile-time `APP_URL` via `--dart-define`, defined in `lib/config.dart`; fallback: raw 6 digits if `APP_URL` is empty). `APP_URL` should point to the Cloudflare Workers deployment (e.g. `https://your-app.workers.dev`). The system camera reads the QR, opens the PWA, the `?code=` param pre-fills the code field and opens the "Inserisci codice" tab. Manual entry remains the primary input method.
- **Deep-link flow**: `main.dart` reads `Uri.base.queryParameters['code']` → `AppShell(pairingCode:)` → `PairingScreen(initialCode:)` opens on the entry tab with code pre-filled. After the code is consumed, **the `?code=` param is stripped from the URL bar** via `history.replaceState` (web-only, `lib/core/clear_url_query_web.dart`; no-op on native via conditional import). This prevents re-triggering the pairing flow on page refresh.
- **Email ready**: seam documented in `PairingService` to graft in email invites when the anonymous identity becomes a real account, without restructuring.

---

## Design system

**Visual system v0.2 applied** — source of truth: `Forkast_Design_Brief_v0.2.md`.

- Centralized theme in `lib/ui/theme.dart` (light + dark). All colour/typography tokens flow from `ForkastTokens` extension and `ThemeData`. No hardcoded colours in screens.
- Wordmark SVG (`assets/forkast-wordmark.svg`) in every screen's app bar via `lib/ui/widgets/forkast_app_bar.dart`.
- Four-voice bottom nav (Piatti / Piano / Lista / Ingredienti) with outline icons, active state in `primary` (v0.6: Ingredienti tab added, FR-23).
- Outline icon family throughout all screens (single family, thin strokes).
- "q.b." rendered as a tenue pill (border background, ink-muted text), not bare text.
- **Dependency noted**: department micro-icons in the shopping list require the `category` attribute on `ingredient` (ADR §7). Grouping by department is active where `category` is set; the micro-icons themselves are not yet implemented.

---

## Unit enum (FR-5, v0.6)

`lib/core/unit.dart` — closed set of units: `grammi` (g), `chilogrammi` (kg), `millilitri` (ml), `litri` (l), `pezzo` (pz). Each unit derives its `roundingKind` (`weight`, `volume`, `whole`), removing the need for the user to pick a rounding strategy separately.

- **Storage**: the canonical short form (`g`, `kg`, `ml`, `l`, `pz`) in the `unit` TEXT column.
- **Migration**: `IngredientRepository.migrateUnitsToEnum()` runs at startup (idempotent). Maps common aliases (`gr` → `g`, `grammi` → `g`, `pezzi` → `pz`, etc.). Unrecognized values are logged and mapped to `pz` as fallback.
- **UI**: ingredient form uses a dropdown selector (no free text).
- **Aggregation**: uses the enum dbValue as key — no more "g" vs "gr" mismatch.

---

## Difficulty & time on dishes (FR-14, v0.6)

`lib/core/dish_enums.dart` — two optional single-choice ordered scales:
- **Difficulty**: `facile`, `medio`, `difficile`
- **Time estimate**: `veloce`, `medio`, `lento`

Stored as nullable TEXT columns `difficulty` and `time_estimate` on `dish` (Supabase migration `00009`).

**Old attributes archived**: the `tag` rows with `group = 'attributo'` and their `dish_tag` links remain in the database but are no longer shown in the UI. They are recoverable if a free-form tagging feature is reintroduced. The tags screen now manages only portate ("Vocabolario portate").

**Filters**: the dish catalog filters by portata + difficulty + time (FR-15).

---

## Open points (flag, don't decide on your own)

- None at the moment.

### Resolved
- "Copy previous week" onto a non-empty week (FR-19): the user chooses **replace or add** at copy time.
- Removing a tag in use (FR-14): **protected** (blocked if in use, shows the count), consistent with FR-17.
- Legacy JWT authentication: HS256→ES256/JWKS migration guide in `docs/auth_jwt_migration.md`. Dashboard configuration only, no code changes.
- Ordering the list by aisle: **fixed list** of aisles in `lib/core/reparto.dart`, nullable `ingredient.category` field (migration `00003`); the shopping list is grouped by aisle in the order of the in-store route.
- Whether the course is mandatory: **stays optional** (product decision). A dish can be saved without a course.

---

## Commands (to complete once setup is done)

```bash
flutter pub get          # dipendenze
flutter run              # avvio in debug su device/emulatore
flutter test             # test (includere i test della regola di riscalo/arrotondamento)
flutter analyze          # lint statico
```
