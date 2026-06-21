# CLAUDE.md — Weekly Menu & Shopping List App

> Context file for Claude Code. Read at every session. Keep it concise and up to date.
> Complete sources of truth: `Requisiti_Funzionali_v0.5.docx`, `Mappa_Flussi_e_Schermate_v1.1.docx`, `ADR_Architettura_v1.1.docx`.
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
- `ingredient` — shared catalog. Owns `unit` and the `is_qb` flag ("to taste").
- `tag` — `portata` (course, single) or `attributo` (attribute, multiple) group, with color and order.
- `dish` + `dish_tag` — reusable dish; one course, multiple attributes.
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
- **Regeneration NOT automatic by default** (FR-21): when the plan diverges from the fingerprint saved on the snapshot, show the "Update" warning; the user decides when. Option for automatic regeneration in settings.

> Offline-first note: cross-device invariants are **best-effort** (UI + reconciliation), not global transactions. This is an accepted limitation (§6 ADR). Do not promise transactional guarantees across devices.

---

## Do / DON'T

**DO**
- Always write locally first, then let PowerSync sync.
- Filter every query by `household_id`; set the access rules (RLS) accordingly.
- Isolate rescaling + rounding in a pure, tested module.
- Generate the list snapshot on an explicit user action, saving the plan hash.

**DON'T**
- No CRDT / Automerge / Yjs.
- Don't sync the generated rows as if they were primary data: derive them.
- Don't tie data to a single device: always to the household.
- No analytics with personal data; no email/PII in this phase.
- Web target is supported. Database opening uses conditional imports (`open_database_native.dart` / `open_database_web.dart`) to avoid `dart:ffi` on the web.

---

## Household bootstrap & device pairing — DONE

Both operations use server-side `SECURITY DEFINER` functions because RLS blocks a device that is not yet a member from writing to `household`/`membership` (chicken-and-egg). See `docs/bootstrap_household.md` for the full rationale.

### Bootstrap (first launch)
- Postgres function `bootstrap_household()` (`supabase/migrations/00006_bootstrap_household.sql`): creates `household` + `membership` atomically for `auth.uid()`, idempotent.
- Client: `lib/data/bootstrap.dart` → `ensureHousehold(db, deviceId)` checks the local DB first (offline-fast path); if no membership is found, calls `rpc('bootstrap_household')`. The rows arrive on the device via PowerSync sync (read, not write).
- Offline fallback: if the RPC fails for network, `BootstrapException` is thrown; the app shows an error screen and retries on next restart. The first launch always requires network (anonymous sign-in).

### Pairing (second device)
- Postgres functions `create_pairing_code()` and `redeem_pairing_code(p_code)` (`supabase/migrations/00002_pairing.sql`): encapsulate the only other privileged writes. `pairing_code` stays server-side, excluded from PowerSync.
- Join model: the second phone **adopts the inviter's household** and abandons its own (empty) bootstrap one; blocked if it already has its own data.
- Client: `lib/data/pairing_service.dart` (`rpc()` wrapper), `PairingScreen` (show code + QR / enter code), `householdId` switchable at runtime via `AppScope.onHouseholdChanged`.
- **QR payload**: `https://<APP_URL>?code=123456` (compile-time `APP_URL`; fallback: raw 6 digits if `APP_URL` is empty). The system camera reads the QR, opens the PWA, the `?code=` param pre-fills the code field and opens the "Inserisci codice" tab. Manual entry remains the primary input method.
- **Deep-link flow**: `main.dart` reads `Uri.base.queryParameters['code']` → `AppShell(pairingCode:)` → `PairingScreen(initialCode:)` opens on the entry tab with code pre-filled.
- **Email ready**: seam documented in `PairingService` to graft in email invites when the anonymous identity becomes a real account, without restructuring.

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
