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

- `household` — container for all data. Owns settings: `default_guests` (FR-8, default 4), `week_start_day` (FR-20, `DateTime.weekday` convention, 0 = unset → falls back to Monday), `seeded_at` (guard against re-seeding). `auto_regen` removed in v0.7 (migration `00013`): regeneration is always automatic and invisible (FR-21 v0.6).
- `membership` — links a device (tomorrow a user) to a household. Basis for pairing.
- `ingredient` — shared catalog. Owns `unit` (from closed enum, FR-5), `is_qb` flag ("to taste"), `always_in_list` (FR-28, recurring), `default_qty` (optional default quantity for recurring).
- `tag` — `portata` (course, single) group, with color and order. Old `attributo` tags archived in DB (v0.6).
- `dish` + `dish_tag` — reusable dish; one course. Has optional `difficulty`, `time_estimate`, and `recipe_url` (TEXT nullable, FR-14/P9, migration `00013`) fields.
- `dish_ingredient` — ingredient row of the dish, `qty_base4` (ignored for `is_qb`).
- `week_plan` → `plan_day` (with the evening's `guests`) → `plan_day_dish` (with `auto_assigned` flag, FR-26).
- `shopping_list` — snapshot context: week, `generated_at`, **fingerprint/hash of the source plan**.
- `list_generated_row` — derived snapshot row (ingredient, rescaled qty, unit).
- `list_override` — reversible modification of a generated row, tied to the `ingredient_id`.
- `list_manual_item` — manually added item (own ID), additive and persistent.
- `list_check` — idempotent check for (list, ingredient); persists across regenerations.
- `list_recurring_exclusion` — per-week suppression of a recurring ingredient (FR-29). Tied to `(shopping_list_id, ingredient_id)`. Does not carry over to the next week.

---

## Invariants and rules to respect in the code

- **Quantities in base 4** (FR-2). Dishes define quantities for 4 people.
- **Rescaling** (FR-11): `qty_finale = qty_base4 × (commensali ÷ 4)`, excluding `is_qb`.
- **Aggregation** (FR-12): sum per catalog item; consistent because an item has a single unit.
- **A SINGLE rounding rule**, in a **shared and tested module** (§5 ADR). E.g. whole-piece products → round up. It must be deterministic. `rounding_kind` is nullable (migration `00012`); `roundForUnit` coalesces NULL to `'weight'`.
- **Unit locked** (FR-16): not editable once the ingredient is used in ≥1 dish. Enforced **in the UI** (the forbidden action isn't even shown) + reconciliation in sync.
- **Protected deletion** (FR-17): an ingredient in use cannot be deleted; show where it is used.
- **Merging duplicates** (FR-18): only when units match.
- **Two-layer list** (FR-21): generated (recreatable snapshot) + manual/override/checks (persistent). Override reversible via "restore".
- **Regeneration automatic and invisible** (FR-21 v0.6): when the plan diverges from the saved fingerprint, the generated layer regenerates silently. No banner, no user action, no setting. Manual layer (checks, overrides, manual items) persists.

> Offline-first note: cross-device invariants are **best-effort** (UI + reconciliation), not global transactions. This is an accepted limitation (§6 ADR). Do not promise transactional guarantees across devices.

---

## Repository layer

All data access goes through `lib/data/repositories/`: `HouseholdRepository`, `IngredientRepository`, `DishRepository`, `TagRepository`, `PlanRepository`, `ListRepository`. Each repo takes `(AppDatabase, householdId)` and filters every query by household (ADR-005). Repositories own business rules (FR-16 unit lock, FR-17 protected delete, FR-18 merge). Never bypass them with raw drift queries in UI code.

---

## Household settings (FR-8/20)

`HouseholdRepository` (`lib/data/repositories/household_repository.dart`) manages two household-level settings:

- **Default guests** (FR-8): `setDefaultGuests(int)` — applied when a new `plan_day` is created. Range 1–99.
- **Week start day** (FR-20): `setWeekStartDay(int)` — `DateTime.weekday` convention (1=Monday…7=Sunday). `orderedWeekdays()` in `lib/core/week.dart` uses this to reorder the 7-day grid in plan view. Schema default 0 falls back to Monday.

**Auto-regen removed** (v0.7): the `auto_regen` field and `setAutoRegen()` were removed (migration `00013`). Regeneration of the generated shopping list layer is always automatic and invisible when the plan hash diverges (FR-21 v0.6). There is no user-facing setting — `_autoRegenIfNeeded()` in `list_screen.dart` fires unconditionally.

UI: Settings screen (`lib/ui/settings/settings_screen.dart`) → Planning section → Default guests dialog (+/− buttons), Week start day radio dialog. Language picker at the bottom.

---

## Dish deletion flow

`lib/ui/dishes/confirm_delete_dish.dart` — `confirmAndDeleteDish()` checks `DishRepository.plannedDinnerCount()` before confirming. If the dish is used in ≥1 planned dinner, shows the count in the dialog ("Usato in N cene"). On confirm, `DishRepository.delete()` cascades: removes `dish_ingredient`, `dish_tag`, `plan_day_dish` rows in a single transaction. The shopping list regenerates from the plan (ADR-004).

---

## Diacritics-insensitive search

`lib/core/diacritics.dart` — `removeDiacritics(String)` strips accents for case- and accent-insensitive matching. Covers Latin-1/Latin Extended-A (Italian, Danish, English). Danish `æ/ø/å` mapped to `ae/oe/aa`. Used in ingredient search filters.

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
- Four-voice bottom nav in data-flow order: **Ingredienti / Piatti / Piano / Lista** (v0.7: reordered per FR-23). Default landing tab: **Piano** (index 2) — the order is narrative, the default follows daily use. Outline icons, active state in `primary`.
- Outline icon family throughout all screens (single family, thin strokes).
- "q.b." rendered as a tenue pill (border background, ink-muted text), not bare text.
- **Dependency noted**: department micro-icons in the shopping list require the `category` attribute on `ingredient` (ADR §7). Grouping by department is active where `category` is set; the micro-icons themselves are not yet implemented.

---

## Unit enum (FR-5, v0.6)

`lib/core/unit.dart` — closed set of units: `grammi` (g), `chilogrammi` (kg), `millilitri` (ml), `litri` (l), `pezzo` (pz). Each unit derives its `roundingKind` (`weight`, `volume`, `whole`), removing the need for the user to pick a rounding strategy separately. `ingredient.rounding_kind` is nullable in both drift and Supabase (migration `00012`); `roundForUnit` and `scaleAndRound` coalesce NULL to `'weight'`.

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

## Recipe URL on dishes (FR-14/P9, v0.7)

`dish.recipe_url` — optional TEXT column (Supabase/drift migration `00013`, PowerSync schema updated). Stores a link to an external recipe.

- **Editor**: `DishEditorScreen` shows a URL text field below the name. When non-empty, a tap icon opens the URL in the external browser via `url_launcher`.
- **Validation**: light — the field accepts any text; if it lacks a scheme prefix, `https://` is prepended before launching.
- **Sync**: the field syncs like any other dish column (PowerSync ↔ Supabase). No special handling.

---

## Plan history & shopping reset (FR-30/31, v0.7)

Week plans persist indefinitely (keyed by `(householdId, year, week)`). No cleanup logic.

- **History view**: `lib/ui/plan/history_screen.dart` — scrollable list of past weeks (reverse-chronological). Each row shows week label + date range; tap expands to show day-by-day dishes + guests (read-only). Reuses `PlanRepository.watchWeekOverview()`. Accessed via history icon in plan screen's week header.
- **`PlanRepository.watchPastWeekPlans()`**: stream of `WeekPlan` rows where `(year, week) < current`, ordered descending.
- **Shopping reset** (FR-31): `ListRepository.resetChecks(listId)` deletes all `list_check` rows for the list. Preserves generated rows, overrides, and manual items. UI: overflow menu in list screen.

---

## "Da quanto non lo facciamo" (FR-24/25, v0.7)

Per-dish "last planned" date, derived at query time (not denormalized). Rationale: the data already exists in `plan_day_dish → plan_day → week_plan`; denormalization would require sync-aware maintenance.

- **`DishRepository.watchLastPlannedMap()`**: custom SQL `MAX(wp.year * 100 + wp.week)` grouped by `dish_id`, filtered to past/current weeks. Returns `Map<String, DateTime>`.
- **`DishRepository.watchAllWithTagsAndLastPlanned()`**: three-way combineLatest (dishes + tags + last-planned map). Returns `List<DishWithLastPlanned>`.
- **Core logic**: `lib/core/last_planned.dart` — `formatLastPlanned(DateTime?, AppLocalizations)` → locale-aware relative time ("3 settimane fa", "mai"). `weeksAgo(DateTime?)` → int for filtering.
- **UI**: dish catalog (`lib/ui/dishes/dishes_screen.dart`) shows "da quanto" subtitle per dish row. Filter bar: "Meno recenti" sort (ascending by `lastPlannedDate`, null first) + "Non fatto da oltre N settimane" filter (predefined: 2, 4, 8 weeks).

---

## "Sorprendimi" (FR-26/27, v0.7)

Fills empty dinner days of the current week with one dish each.

- **Pure logic**: `lib/core/surprise_me.dart` — `selectSurpriseDishes()` takes empty days, already-assigned dish IDs, candidate dishes with last-planned dates, optional weekday difficulty/time filters. Algorithm: for each empty day, filter by day-type constraints → remove used → sort by `lastPlannedDate` ascending (null first) → pick top. Returns `SurpriseMeResult` with assignment map and partial-fill flag.
- **`plan_day_dish.auto_assigned`** (BOOLEAN DEFAULT false, migration `00014`): tracks auto-inserted dishes. Survives app restart and sync.
- **`PlanRepository.surpriseMe(year, week)`**: gathers empty days, fetches candidates with last-planned dates, calls `selectSurpriseDishes()`, inserts via `addDishes(autoAssigned: true)`.
- **`PlanRepository.undoSurpriseMe(year, week)`**: deletes `plan_day_dish` rows where `auto_assigned = true` within the week.
- **`PlanRepository.watchHasAutoAssigned(year, week)`**: stream for showing/hiding the undo button.
- **UI**: plan screen (`lib/ui/plan/plan_screen.dart`) — "Sorprendimi" button (wand icon) + "Annulla" (undo, shown when auto-assigned dishes exist). Snackbar for partial fill warning.

---

## Recurring / "Sempre in lista" (FR-28/29, v0.7)

Ingredients marked `always_in_list` appear in every shopping list regardless of the menu.

- **Schema** (migration `00014`): `ingredient.always_in_list` (BOOLEAN DEFAULT false), `ingredient.default_qty` (REAL nullable). New table `list_recurring_exclusion` (id, shopping_list_id, ingredient_id, household_id, created_at) for per-week suppression.
- **Aggregation**: recurring ingredients are fed as synthetic `ListLineInput` with `guests: 4` (identity scaling: `scaleQty(qtyBase4: x, guests: 4) = x`). They pass through `aggregateList()` unchanged — if the same ingredient also comes from the plan, quantities sum naturally (FR-12). The pure `list_generation.dart` module is NOT modified.
- **Plan hash**: combined hash of plan-derived lines + recurring lines. `watchPlanHash()` reacts to both plan table changes and `ingredient.always_in_list` / `default_qty` changes.
- **Per-week exclusion** (FR-29): `ListRepository.excludeRecurring(listId, ingredientId)` inserts into `list_recurring_exclusion`. Scoped by `shoppingListId` — new week = new list = exclusion doesn't carry over. `includeRecurring()` deletes the exclusion row.
- **UI**: ingredient form (`lib/ui/settings/ingredient_form.dart`) — "Sempre in lista" toggle + conditional default qty field. Ingredient catalog — "Ricorrenti" filter. List screen — "ricorrente" label on recurring items; "Escludi questa settimana" action in row bottom sheet.

---

## Autocomplete in dish editor (D3, v0.7)

The ingredient picker in `DishEditorScreen` (`_IngredientPicker`) provides:

- **Search**: diacritics-insensitive substring matching on the localized display name, via `removeDiacritics()`.
- **Fuzzy matching**: when creating a new ingredient, a Levenshtein distance check (threshold ≤ 2) finds similar existing entries and warns the user before creating a potential duplicate.
- **Anti-duplicate**: creating a new ingredient is a deliberate action. If similar ingredients exist, a confirmation dialog lists them and the user must tap "Create anyway".
- **No unit field on dish row**: the ingredient row in the dish editor inherits unit/qb from the catalog entry. Selecting an existing ingredient references the existing entry (no new catalog rows).

---

## Localization (L1 + L2)

**L1 — UI i18n (it/en/da).** All UI strings externalized via `flutter_localizations` + `intl` + `gen-l10n`. ARB files in `lib/l10n/` (source: `app_it.arb`). Generated code in `lib/l10n/generated/`. Run `flutter gen-l10n` after editing ARB files.

- **Locale provider**: `lib/core/locale_provider.dart` — `LocaleNotifier` backed by `SharedPreferences`. Per-device, NOT synced. Two phones in the same household can use different languages.
- **Language selector**: Settings screen → Language. Hot-swap via `ListenableBuilder` on the notifier; no restart needed.
- **Enum labels localized**: `lib/core/l10n_enums.dart` — extension methods `localizedLabel(AppLocalizations l)` on `Unit`, `Difficulty`, `TimeEstimate`. Reparti: `localizedReparto(String? dbKey, AppLocalizations l)`.
- **Numbers locale-aware**: `formatQty()` in `lib/core/qty_format.dart` now takes a `locale` parameter. Comma in it/da, dot in en.
- **Weekday/month names**: use `intl` `DateFormat.EEEE(locale)` / `DateFormat.E(locale)` / `DateFormat.MMM(locale)` — no hardcoded names.
- **System always metric**: no unit conversion. The `Unit` enum and its `dbValue` are language-neutral; only the display label is translated.

**L2 — Localizable seeded content.**

- **Schema**: `seed_key TEXT` and `name_modified BOOLEAN DEFAULT false` on both `ingredient` and `dish` tables (migration `00011`, drift, PowerSync schema).
- **seed_key**: stable kebab-case slug assigned to each seeded entry. User-created entries have `seed_key = null`. Syncs across devices.
- **Translation bundle**: `assets/seed_translations.json` — `{ "seed-key": { "it": "Nome", "en": "Name", "da": "Navn" } }`. Currently contains only Italian names; en/da translations are a data task to be completed separately.
- **Display-time resolution** (`lib/core/seed_name_resolver.dart`): `SeedNameResolver.instance.resolve(storedName, seedKey, nameModified, locale)` — returns translated name for seeded items, stored name for user-created/modified items. Loaded at bootstrap.
- **"Edit disconnects" rule**: when the user renames a seeded ingredient, `name_modified` is set to `true` in `IngredientRepository.update()`. The item stops auto-translating. Editing category/unit/qb does NOT disconnect.
- **Aggregation identity**: shopping list aggregation and dish→ingredient references use `id` (UUID), never the display name string. Language changes cannot break or merge list rows.
- **Seed CSV**: `assets/seed_ingredienti.csv` now has a `seed_key` column. `seed_catalog.dart` writes it on insert.
- **Seeding guard**: `household.seeded_at` — once set, the catalog seed never re-runs (not on restart, not on paired device). The check is `count > 0 || seededAt != null`.
- **Startup backfills** (idempotent, run in `app_scope` or bootstrap): `backfillSeedKeys()` — matches existing ingredients by Italian name to assign `seed_key` for pre-L2 entries. `backfillRoundingKind()` — fills NULL `rounding_kind` from the unit enum (fixes q.b. items seeded before the fix).
- **Helper**: `lib/core/display_name.dart` — `ingredientDisplayName(ing, locale)`, `dishDisplayName(dish, locale)`.

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

## Test infrastructure

- **Unit tests** in `test/`: organized by layer (`test/core/`, `test/data/`, root-level).
- **`AppDatabase.forTesting(connection)`**: constructor that takes any drift `QueryExecutor` (typically in-memory SQLite). No PowerSync, no sync bridge. Allows testing repository logic with a real schema minus PowerSync's table management.
- **Key test suites**: `scaling_test` (rounding/rescaling), `list_generation_test` (aggregation), `ingredient_rules_test` (FR-16/17/18), `plan_repository_test` (copy week), `tag_repository_test` (protected deletion), `powersync_connector_test` (fatal error classification), `seed_catalog_test`, `seed_name_resolver_test`, `display_name_test`, `qty_format_test`, `dish_repository_test` (CRUD + recipe_url), `household_repository_test` (settings), `ingredient_filter_test` (combined filters), `surprise_me_test` (P14 selection logic), `last_planned_test` (P13 weeksAgo).
- **Browser test suite** (manual): `docs/Forkast_Browser_Test_Suite.md` — E2E checklist for the deployed web app. Covers infra, sync, reactivity, calculation, two-layer list, localization, pairing, deletion, ingredient constraints, dish filters, plan navigation/copy/guests, reparti. See Manutenzione section below.

---

## Commands

```bash
flutter pub get          # dipendenze
flutter run              # avvio in debug su device/emulatore
flutter test             # test (includere i test della regola di riscalo/arrotondamento)
flutter analyze          # lint statico
```


## Manutenzione (importante)

Questa suite è **viva**: ogni feature o fix che tocca un'area qui sotto deve aggiungere/aggiornare un caso BT.

**Convenzione per ogni nuovo caso:**
- ID progressivo `BT-NN` nella sezione giusta.
- Colonna **"Previene"**: il bug/feature che il caso protegge (così non viene cancellato per sbaglio e si capisce perché esiste).
- Priorità: 🔴 = entra nello SMOKE SET (regressione critica, ogni deploy) · 🟡 = standard · ⚪ = opzionale.

```
Esiste una browser test suite manuale in docs/Forkast_Browser_Test_Suite.md per i comportamenti verificabili solo dal
vivo (infrastruttura, header COOP/COEP, sync PowerSync, RLS, reattività degli stream, localizzazione, pairing
multi-dispositivo, vincoli ingredienti FR-16/17/18, filtri piatti FR-14/15, piano settimanale FR-19/20, reparti FR-23).
Regola: quando scrivi codice che tocca una di queste aree — schema/migration, powersync_connector, bootstrap,
RLS/policy, bridge db.updates, rigenerazione lista, localizzazione, deploy/wrangler/header, vincoli ingredienti,
filtri piatti, copia settimana, ospiti, reparti — aggiungi o aggiorna il caso BT corrispondente in quel file, con la
colonna "Previene" che cita il bug/feature. Se il cambiamento introduce una regressione critica, marca il caso
🔴 (smoke set). Non rimuovere casi BT senza motivo esplicito.
```