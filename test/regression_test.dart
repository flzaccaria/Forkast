import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/ingredient_repository.dart';
import 'package:forkast/data/repositories/list_repository.dart';

/// Regression tests targeting the exact bug patterns that have hit this project:
///   - Stream reactivity (drift watch not re-emitting)
///   - Nullable schema (PowerSync serves all-nullable rows)
///   - PowerSync ↔ drift bridge (table name mapping)
///
/// All tests use AppDatabase.forTesting with "PowerSync-style" schema (no
/// DEFAULT, no NOT NULL) to surface client assumptions.

// ---------------------------------------------------------------------------
// Schema helper — reusable PowerSync-style DDL
// ---------------------------------------------------------------------------

Future<void> _createSchema(AppDatabase db) async {
  Future<void> exec(String sql) => db.customStatement(sql);
  await exec('''CREATE TABLE household (
    id TEXT PRIMARY KEY, name TEXT, default_guests INTEGER,
    week_start_day INTEGER, seeded_at TEXT,
    created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE membership (
    id TEXT PRIMARY KEY, household_id TEXT, device_id TEXT,
    role TEXT, joined_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE ingredient (
    id TEXT PRIMARY KEY, household_id TEXT, name TEXT, unit TEXT,
    is_qb INTEGER, category TEXT, rounding_kind TEXT,
    seed_key TEXT, name_modified INTEGER, created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE tag (
    id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
    tag_group TEXT, color TEXT, sort_order INTEGER,
    created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE dish (
    id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
    difficulty TEXT, time_estimate TEXT, recipe_url TEXT,
    seed_key TEXT, name_modified INTEGER,
    created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE dish_tag (
    id TEXT PRIMARY KEY, dish_id TEXT, tag_id TEXT,
    household_id TEXT, created_at TEXT)''');
  await exec('''CREATE TABLE dish_ingredient (
    id TEXT PRIMARY KEY, dish_id TEXT, ingredient_id TEXT,
    household_id TEXT, qty_base4 REAL, created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE week_plan (
    id TEXT PRIMARY KEY, household_id TEXT, year INTEGER, week INTEGER,
    created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE plan_day (
    id TEXT PRIMARY KEY, week_plan_id TEXT, household_id TEXT,
    day_of_week INTEGER, guests INTEGER, created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE plan_day_dish (
    id TEXT PRIMARY KEY, plan_day_id TEXT, dish_id TEXT,
    household_id TEXT, sort_order INTEGER, created_at TEXT)''');
  await exec('''CREATE TABLE shopping_list (
    id TEXT PRIMARY KEY, household_id TEXT, week_plan_id TEXT,
    generated_at TEXT, plan_hash TEXT, created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE list_generated_row (
    id TEXT PRIMARY KEY, shopping_list_id TEXT, ingredient_id TEXT,
    household_id TEXT, qty REAL, unit TEXT, is_qb INTEGER, created_at TEXT)''');
  await exec('''CREATE TABLE list_override (
    id TEXT PRIMARY KEY, shopping_list_id TEXT, ingredient_id TEXT,
    household_id TEXT, qty_override REAL, removed INTEGER,
    created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE list_manual_item (
    id TEXT PRIMARY KEY, shopping_list_id TEXT, household_id TEXT,
    name TEXT, qty REAL, unit TEXT, created_at TEXT, updated_at TEXT)''');
  await exec('''CREATE TABLE list_check (
    id TEXT PRIMARY KEY, shopping_list_id TEXT, ingredient_id TEXT,
    manual_item_id TEXT, household_id TEXT, checked INTEGER, updated_at TEXT)''');
}

const _hh = 'hh-1';
const _wp = 'wp-1';

Future<void> _seedHousehold(AppDatabase db) async {
  final now = DateTime.now().toUtc();
  await db.into(db.households).insert(HouseholdsCompanion.insert(
        id: _hh,
        defaultGuests: const Value(4),
        weekStartDay: const Value(1),

        createdAt: now,
        updatedAt: now,
      ));
  await db.into(db.weekPlans).insert(WeekPlansCompanion.insert(
        id: _wp,
        householdId: _hh,
        year: 2026,
        week: 26,
        createdAt: now,
        updatedAt: now,
      ));
}

void main() {
  // =========================================================================
  // A) STREAM REACTIVITY
  // =========================================================================

  group('A — stream reactivity', () {
    late AppDatabase db;
    late IngredientRepository ingredientRepo;
    late ListRepository listRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await _createSchema(db);
      await _seedHousehold(db);
      ingredientRepo = IngredientRepository(db, _hh);
      listRepo = ListRepository(db, _hh);
    });

    tearDown(() async => db.close());

    // Regression: ingredient catalog didn't refresh after adding a new item
    // because the stream wasn't invalidated by the insert.
    test('watchAll re-emits after a local insert', () async {
      final emissions = <List<Ingredient>>[];
      final sub = ingredientRepo.watchAll().listen(emissions.add);
      await pumpEventQueue();

      expect(emissions, hasLength(1), reason: 'initial emission');
      expect(emissions.last, isEmpty);

      await ingredientRepo.create(name: 'Pasta', unit: 'g');
      await pumpEventQueue();

      expect(emissions, hasLength(2), reason: 'must re-emit after insert');
      expect(emissions.last, hasLength(1));
      expect(emissions.last.single.name, 'Pasta');

      await sub.cancel();
    });

    // Regression: shopping list didn't update live when a dish was added to
    // the plan — watchPlanHash wasn't wired to plan_day_dish.
    test('watchPlanHash re-emits when plan_day_dish changes', () async {
      final now = DateTime.now().toUtc();
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'i1', householdId: _hh, name: 'Carne', unit: 'g',
            isQb: const Value(false), roundingKind: const Value('weight'),
            createdAt: now, updatedAt: now));
      await db.into(db.dishes).insert(DishesCompanion.insert(
            id: 'd1', householdId: _hh, name: 'Bistecca',
            createdAt: now, updatedAt: now));
      await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
            id: 'di1', dishId: 'd1', ingredientId: 'i1', householdId: _hh,
            qtyBase4: const Value(600), createdAt: now, updatedAt: now));
      await db.into(db.planDays).insert(PlanDaysCompanion.insert(
            id: 'pd1', weekPlanId: _wp, householdId: _hh,
            dayOfWeek: 1, guests: 4, createdAt: now, updatedAt: now));

      final hashes = <String>[];
      final sub = listRepo.watchPlanHash(_wp).listen(hashes.add);
      await pumpEventQueue();

      expect(hashes, hasLength(1), reason: 'initial hash (empty plan)');

      await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
            id: 'pdd1', planDayId: 'pd1', dishId: 'd1', householdId: _hh,
            sortOrder: const Value(0), createdAt: now));
      await pumpEventQueue();

      expect(hashes, hasLength(2), reason: 'must re-emit after dish added');
      expect(hashes[0], isNot(hashes[1]));

      await sub.cancel();
    });

    // Regression: list screen only watched shopping_list, so writes to
    // override / manual_item / check didn't trigger a refresh.
    test('watchGeneratedItems re-emits on list_override write', () async {
      final now = DateTime.now().toUtc();
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'i1', householdId: _hh, name: 'Carne', unit: 'g',
            isQb: const Value(false), roundingKind: const Value('weight'),
            createdAt: now, updatedAt: now));
      await db.into(db.dishes).insert(DishesCompanion.insert(
            id: 'd1', householdId: _hh, name: 'Bistecca',
            createdAt: now, updatedAt: now));
      await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
            id: 'di1', dishId: 'd1', ingredientId: 'i1', householdId: _hh,
            qtyBase4: const Value(600), createdAt: now, updatedAt: now));
      await db.into(db.planDays).insert(PlanDaysCompanion.insert(
            id: 'pd1', weekPlanId: _wp, householdId: _hh,
            dayOfWeek: 1, guests: 4, createdAt: now, updatedAt: now));
      await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
            id: 'pdd1', planDayId: 'pd1', dishId: 'd1', householdId: _hh,
            sortOrder: const Value(0), createdAt: now));

      final listId = await listRepo.generate(_wp);

      final emissions = <List<GeneratedItemView>>[];
      final sub = listRepo.watchGeneratedItems(listId).listen(emissions.add);
      await pumpEventQueue();

      expect(emissions, hasLength(1));
      expect(emissions.last.single.hasOverride, false);

      await listRepo.setOverrideQty(listId, 'i1', 500);
      await pumpEventQueue();

      expect(emissions, hasLength(2),
          reason: 'override write must re-emit generated stream');
      expect(emissions.last.single.hasOverride, true);
      expect(emissions.last.single.displayQty, 500);

      await sub.cancel();
    });

    // Regression: check write didn't re-emit the generated stream.
    test('watchGeneratedItems re-emits on list_check write', () async {
      final now = DateTime.now().toUtc();
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'i1', householdId: _hh, name: 'Carne', unit: 'g',
            isQb: const Value(false), roundingKind: const Value('weight'),
            createdAt: now, updatedAt: now));
      await db.into(db.dishes).insert(DishesCompanion.insert(
            id: 'd1', householdId: _hh, name: 'Bistecca',
            createdAt: now, updatedAt: now));
      await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
            id: 'di1', dishId: 'd1', ingredientId: 'i1', householdId: _hh,
            qtyBase4: const Value(600), createdAt: now, updatedAt: now));
      await db.into(db.planDays).insert(PlanDaysCompanion.insert(
            id: 'pd1', weekPlanId: _wp, householdId: _hh,
            dayOfWeek: 1, guests: 4, createdAt: now, updatedAt: now));
      await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
            id: 'pdd1', planDayId: 'pd1', dishId: 'd1', householdId: _hh,
            sortOrder: const Value(0), createdAt: now));

      final listId = await listRepo.generate(_wp);

      final emissions = <List<GeneratedItemView>>[];
      final sub = listRepo.watchGeneratedItems(listId).listen(emissions.add);
      await pumpEventQueue();

      expect(emissions.last.single.checked, false);

      await listRepo.setIngredientChecked(listId, 'i1', true);
      await pumpEventQueue();

      expect(emissions.length, greaterThanOrEqualTo(2),
          reason: 'check write must re-emit generated stream');
      expect(emissions.last.single.checked, true);

      await sub.cancel();
    });

    // Regression: manual items written to list_manual_item didn't show up
    // until refresh.
    test('watchManualItems re-emits on manual item add', () async {
      final now = DateTime.now().toUtc();
      await db.into(db.ingredients).insert(IngredientsCompanion.insert(
            id: 'i1', householdId: _hh, name: 'Carne', unit: 'g',
            isQb: const Value(false), createdAt: now, updatedAt: now));
      await db.into(db.dishes).insert(DishesCompanion.insert(
            id: 'd1', householdId: _hh, name: 'Bistecca',
            createdAt: now, updatedAt: now));
      await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
            id: 'di1', dishId: 'd1', ingredientId: 'i1', householdId: _hh,
            qtyBase4: const Value(600), createdAt: now, updatedAt: now));
      await db.into(db.planDays).insert(PlanDaysCompanion.insert(
            id: 'pd1', weekPlanId: _wp, householdId: _hh,
            dayOfWeek: 1, guests: 4, createdAt: now, updatedAt: now));
      await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
            id: 'pdd1', planDayId: 'pd1', dishId: 'd1', householdId: _hh,
            sortOrder: const Value(0), createdAt: now));

      final listId = await listRepo.generate(_wp);

      final emissions = <List<ManualItemView>>[];
      final sub = listRepo.watchManualItems(listId).listen(emissions.add);
      await pumpEventQueue();

      expect(emissions.last, isEmpty);

      await listRepo.addManualItem(listId, name: 'Tovaglioli');
      await pumpEventQueue();

      expect(emissions.length, greaterThanOrEqualTo(2),
          reason: 'manual item add must re-emit manual stream');
      expect(emissions.last.single.name, 'Tovaglioli');

      await sub.cancel();
    });

    // Regression: PowerSync bridge filtered by known table names; if the set
    // was incomplete, sync-down writes would silently not refresh drift
    // streams.
    test('allTables contains every table the app uses', () {
      final names = db.allTables.map((t) => t.actualTableName).toSet();
      const expected = {
        'household', 'membership', 'ingredient', 'tag', 'dish', 'dish_tag',
        'dish_ingredient', 'week_plan', 'plan_day', 'plan_day_dish',
        'shopping_list', 'list_generated_row', 'list_override',
        'list_manual_item', 'list_check',
      };
      for (final table in expected) {
        expect(names, contains(table),
            reason: 'PowerSync bridge would silently skip "$table" updates');
      }
    });
  });

  // =========================================================================
  // B) NULLABLE SCHEMA — PowerSync sends all-nullable rows
  // =========================================================================

  group('B — nullable schema', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await _createSchema(db);
      await _seedHousehold(db);
    });

    tearDown(() async => db.close());

    // Regression: name_modified NULL from PowerSync caused "Null check
    // operator used on a null value" when drift tried to map bool.
    test('ingredient with name_modified=NULL reads without crash', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await db.customStatement(
        "INSERT INTO ingredient (id, household_id, name, unit, is_qb, "
        "name_modified, created_at, updated_at) "
        "VALUES ('i-nm', '$_hh', 'Test', 'g', 0, NULL, '$now', '$now')",
      );

      final repo = IngredientRepository(db, _hh);
      final all = await repo.watchAll().first;
      expect(all.single.nameModified, isNull);
    });

    // Regression: same bug on dish.name_modified.
    test('dish with name_modified=NULL reads without crash', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await db.customStatement(
        "INSERT INTO dish (id, household_id, name, name_modified, "
        "created_at, updated_at) "
        "VALUES ('d-nm', '$_hh', 'Risotto', NULL, '$now', '$now')",
      );

      final all = await (db.select(db.dishes)
            ..where((d) => d.id.equals('d-nm')))
          .get();
      expect(all.single.nameModified, isNull);
    });

    // Regression: dish editor crashed when difficulty/time_estimate/seed_key/
    // category were all NULL (PowerSync default for newly synced rows).
    test('fully-nullable optional columns read without error', () async {
      final now = DateTime.now().toUtc().toIso8601String();
      await db.customStatement(
        "INSERT INTO ingredient (id, household_id, name, unit, is_qb, "
        "rounding_kind, category, seed_key, name_modified, "
        "created_at, updated_at) "
        "VALUES ('i-all', '$_hh', 'Farina', 'g', 0, "
        "NULL, NULL, NULL, NULL, '$now', '$now')",
      );
      await db.customStatement(
        "INSERT INTO dish (id, household_id, name, difficulty, time_estimate, "
        "seed_key, name_modified, created_at, updated_at) "
        "VALUES ('d-all', '$_hh', 'Pane', NULL, NULL, NULL, NULL, "
        "'$now', '$now')",
      );

      final ingredients = await (db.select(db.ingredients)
            ..where((i) => i.id.equals('i-all')))
          .get();
      final ing = ingredients.single;
      expect(ing.roundingKind, isNull);
      expect(ing.category, isNull);
      expect(ing.seedKey, isNull);
      expect(ing.nameModified, isNull);

      final dishes = await (db.select(db.dishes)
            ..where((d) => d.id.equals('d-all')))
          .get();
      final dish = dishes.single;
      expect(dish.difficulty, isNull);
      expect(dish.timeEstimate, isNull);
      expect(dish.seedKey, isNull);
      expect(dish.nameModified, isNull);
    });

    // Regression: watchGeneratedItems custom query crashed when the joined
    // ingredient had NULL seed_key / name_modified — the readNullable calls
    // must handle this.
    test('watchGeneratedItems handles NULL seed_key and name_modified', () async {
      final now = DateTime.now().toUtc();
      await db.customStatement(
        "INSERT INTO ingredient (id, household_id, name, unit, is_qb, "
        "seed_key, name_modified, created_at, updated_at) "
        "VALUES ('i1', '$_hh', 'Farina', 'g', 0, NULL, NULL, "
        "'${now.toIso8601String()}', '${now.toIso8601String()}')",
      );
      await db.into(db.dishes).insert(DishesCompanion.insert(
            id: 'd1', householdId: _hh, name: 'Pane',
            createdAt: now, updatedAt: now));
      await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
            id: 'di1', dishId: 'd1', ingredientId: 'i1', householdId: _hh,
            qtyBase4: const Value(500), createdAt: now, updatedAt: now));
      await db.into(db.planDays).insert(PlanDaysCompanion.insert(
            id: 'pd1', weekPlanId: _wp, householdId: _hh,
            dayOfWeek: 1, guests: 4, createdAt: now, updatedAt: now));
      await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
            id: 'pdd1', planDayId: 'pd1', dishId: 'd1', householdId: _hh,
            sortOrder: const Value(0), createdAt: now));

      final listRepo = ListRepository(db, _hh);
      final listId = await listRepo.generate(_wp);

      final items = await listRepo.watchGeneratedItems(listId).first;
      expect(items, hasLength(1));
      expect(items.single.seedKey, isNull);
      expect(items.single.nameModified, false,
          reason: 'NULL name_modified in custom query must coalesce to false');
    });
  });
}
