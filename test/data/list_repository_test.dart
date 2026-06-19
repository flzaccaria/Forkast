import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/list_repository.dart';

/// Flusso lista a due strati (FR-10/11/12/13/21) su schema "stile PowerSync"
/// (tabelle senza DEFAULT), che intercetta anche i default drift non applicati
/// (is_qb, removed, checked).
void main() {
  late AppDatabase db;
  late ListRepository repo;
  const householdId = 'hh-1';
  const weekPlanId = 'wp-1';

  Future<void> exec(String sql) => db.customStatement(sql);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await exec('''CREATE TABLE household (
      id TEXT PRIMARY KEY, name TEXT, default_guests INTEGER,
      week_start_day INTEGER, auto_regen INTEGER, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE ingredient (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT, unit TEXT,
      is_qb INTEGER, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish_ingredient (
      id TEXT PRIMARY KEY, dish_id TEXT, ingredient_id TEXT, household_id TEXT,
      qty_base4 REAL, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE week_plan (
      id TEXT PRIMARY KEY, household_id TEXT, year INTEGER, week INTEGER,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE plan_day (
      id TEXT PRIMARY KEY, week_plan_id TEXT, household_id TEXT,
      day_of_week INTEGER, guests INTEGER, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE plan_day_dish (
      id TEXT PRIMARY KEY, plan_day_id TEXT, dish_id TEXT, household_id TEXT,
      sort_order INTEGER, created_at TEXT)''');
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
      id TEXT PRIMARY KEY, shopping_list_id TEXT, household_id TEXT, name TEXT,
      qty REAL, unit TEXT, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE list_check (
      id TEXT PRIMARY KEY, shopping_list_id TEXT, ingredient_id TEXT,
      manual_item_id TEXT, household_id TEXT, checked INTEGER, updated_at TEXT)''');

    final now = DateTime.now().toUtc();
    await db.into(db.households).insert(HouseholdsCompanion.insert(
          id: householdId,
          defaultGuests: const Value(4),
          weekStartDay: const Value(1),
          autoRegen: const Value(false),
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.weekPlans).insert(WeekPlansCompanion.insert(
          id: weekPlanId,
          householdId: householdId,
          year: 2026,
          week: 25,
          createdAt: now,
          updatedAt: now,
        ));
    repo = ListRepository(db, householdId);
  });

  tearDown(() async => db.close());

  Future<void> seedIngredient(String id, String name,
      {String unit = 'g', bool isQb = false}) async {
    final now = DateTime.now().toUtc();
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: id,
          householdId: householdId,
          name: name,
          unit: unit,
          isQb: Value(isQb),
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> seedDishIngredient(String dishId, String ingredientId,
      double? qtyBase4) async {
    final now = DateTime.now().toUtc();
    await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
          id: 'di-$dishId-$ingredientId',
          dishId: dishId,
          ingredientId: ingredientId,
          householdId: householdId,
          qtyBase4: Value(qtyBase4),
          createdAt: now,
          updatedAt: now,
        ));
  }

  /// Crea una serata con un piatto e i suoi ingredienti.
  Future<void> seedDinner({
    required int dayOfWeek,
    required int guests,
    required String dishId,
  }) async {
    final now = DateTime.now().toUtc();
    final planDayId = 'pd-$dayOfWeek';
    await db.into(db.dishes).insert(DishesCompanion.insert(
          id: dishId,
          householdId: householdId,
          name: dishId,
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.planDays).insert(PlanDaysCompanion.insert(
          id: planDayId,
          weekPlanId: weekPlanId,
          householdId: householdId,
          dayOfWeek: dayOfWeek,
          guests: guests,
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
          id: 'pdd-$dayOfWeek-$dishId',
          planDayId: planDayId,
          dishId: dishId,
          householdId: householdId,
          sortOrder: const Value(0),
          createdAt: now,
        ));
  }

  test('generate riscala e aggrega, salva snapshot e hash', () async {
    await seedIngredient('carne', 'Carne');
    await seedIngredient('sale', 'Sale', isQb: true);
    await seedDinner(dayOfWeek: 1, guests: 6, dishId: 'd1'); // x1.5
    await seedDishIngredient('d1', 'carne', 600); // -> 900
    await seedDishIngredient('d1', 'sale', null);

    final listId = await repo.generate(weekPlanId);

    final list = await repo.watchList(weekPlanId).first;
    expect(list, isNotNull);
    expect(list!.id, listId);
    expect(list.planHash, isNotEmpty);

    final items = await repo.watchGeneratedItems(listId).first;
    final carne = items.firstWhere((i) => i.ingredientId == 'carne');
    final sale = items.firstWhere((i) => i.ingredientId == 'sale');
    expect(carne.displayQty, 900);
    expect(sale.isQb, true);
    expect(sale.displayQty, isNull);
  });

  test('override: modifica, rimozione e ripristino', () async {
    await seedIngredient('carne', 'Carne');
    await seedDinner(dayOfWeek: 1, guests: 4, dishId: 'd1');
    await seedDishIngredient('d1', 'carne', 600);
    final listId = await repo.generate(weekPlanId);

    await repo.setOverrideQty(listId, 'carne', 500);
    var item = (await repo.watchGeneratedItems(listId).first).single;
    expect(item.hasOverride, true);
    expect(item.displayQty, 500);

    await repo.removeGeneratedRow(listId, 'carne');
    item = (await repo.watchGeneratedItems(listId).first).single;
    expect(item.removed, true);

    await repo.restoreGeneratedRow(listId, 'carne');
    item = (await repo.watchGeneratedItems(listId).first).single;
    expect(item.hasOverride, false);
    expect(item.removed, false);
    expect(item.displayQty, 600);
  });

  test('voci manuali: aggiunta e rimozione', () async {
    await seedIngredient('carne', 'Carne');
    await seedDinner(dayOfWeek: 1, guests: 4, dishId: 'd1');
    await seedDishIngredient('d1', 'carne', 600);
    final listId = await repo.generate(weekPlanId);

    await repo.addManualItem(listId, name: 'Tovaglioli', qty: 2, unit: 'pz');
    var manual = await repo.watchManualItems(listId).first;
    expect(manual.single.name, 'Tovaglioli');

    await repo.removeManualItem(listId, manual.single.id);
    manual = await repo.watchManualItems(listId).first;
    expect(manual, isEmpty);
  });

  test('le spunte persistono attraverso la rigenerazione (FR-21)', () async {
    await seedIngredient('carne', 'Carne');
    await seedDinner(dayOfWeek: 1, guests: 4, dishId: 'd1');
    await seedDishIngredient('d1', 'carne', 600);
    final listId = await repo.generate(weekPlanId);

    await repo.setIngredientChecked(listId, 'carne', true);
    expect((await repo.watchGeneratedItems(listId).first).single.checked, true);

    // Rigenera: lo snapshot si ricrea, la spunta resta.
    await repo.generate(weekPlanId);
    expect((await repo.watchGeneratedItems(listId).first).single.checked, true);

    await repo.setIngredientChecked(listId, 'carne', false);
    expect(
        (await repo.watchGeneratedItems(listId).first).single.checked, false);
  });

  test('currentPlanHash diverge quando cambia il piano', () async {
    await seedIngredient('carne', 'Carne');
    await seedDinner(dayOfWeek: 1, guests: 4, dishId: 'd1');
    await seedDishIngredient('d1', 'carne', 600);
    await repo.generate(weekPlanId);
    final list = await repo.watchList(weekPlanId).first;

    // Cambia i commensali della serata.
    await (db.update(db.planDays)..where((d) => d.id.equals('pd-1')))
        .write(const PlanDaysCompanion(guests: Value(8)));

    final current = await repo.currentPlanHash(weekPlanId);
    expect(current, isNot(list!.planHash));
  });
}
