import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/dish_repository.dart';

/// Creation, modification and deletion of dishes on a "PowerSync-style" schema
/// (without DEFAULT).
void main() {
  late AppDatabase db;
  late DishRepository repo;
  const householdId = 'hh-1';

  Future<void> exec(String sql) => db.customStatement(sql);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await exec('''CREATE TABLE ingredient (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT, unit TEXT,
      is_qb INTEGER, category TEXT, rounding_kind TEXT,
      seed_key TEXT, name_modified INTEGER DEFAULT 0,
      always_in_list INTEGER DEFAULT 0, default_qty REAL,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
      difficulty TEXT, time_estimate TEXT, recipe_url TEXT,
      seed_key TEXT, name_modified INTEGER DEFAULT 0,
      always_in_list INTEGER DEFAULT 0, default_qty REAL,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish_ingredient (
      id TEXT PRIMARY KEY, dish_id TEXT, ingredient_id TEXT, household_id TEXT,
      qty_base4 REAL, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE tag (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT, "group" TEXT,
      color TEXT, sort_order INTEGER, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish_tag (
      id TEXT PRIMARY KEY, dish_id TEXT, tag_id TEXT, household_id TEXT,
      created_at TEXT)''');
    await exec('''CREATE TABLE week_plan (
      id TEXT PRIMARY KEY, household_id TEXT, year INTEGER, week INTEGER,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE plan_day (
      id TEXT PRIMARY KEY, week_plan_id TEXT, household_id TEXT,
      day_of_week INTEGER, guests INTEGER, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE plan_day_dish (
      id TEXT PRIMARY KEY, plan_day_id TEXT, dish_id TEXT, household_id TEXT,
      sort_order INTEGER, auto_assigned INTEGER DEFAULT 0, created_at TEXT)''');
    repo = DishRepository(db, householdId);
  });

  tearDown(() async => db.close());

  Future<void> seedIngredient(String id, {bool isQb = false}) async {
    final now = DateTime.now().toUtc();
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: id,
          householdId: householdId,
          name: id,
          unit: 'g',
          isQb: Value(isQb),
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<String> seedTag(String id, String group) async {
    final now = DateTime.now().toUtc();
    await db.into(db.tags).insert(TagsCompanion.insert(
          id: id,
          householdId: householdId,
          name: id,
          tagGroup: group,
          sortOrder: const Value(0),
          createdAt: now,
          updatedAt: now,
        ));
    return id;
  }

  test('create saves name, ingredients and tags', () async {
    await seedIngredient('carne');
    await seedTag('primo', 'portata');
    final id = await repo.create(
      name: 'Ragù',
      ingredients: [DishIngredientDraft(ingredientId: 'carne', qtyBase4: 600)],
      tagIds: ['primo'],
    );
    expect((await repo.getDish(id))!.name, 'Ragù');
    expect((await repo.getIngredients(id)).single.qtyBase4, 600);
  });

  test('update rewrites name, ingredients and tags', () async {
    await seedIngredient('carne');
    await seedIngredient('sale', isQb: true);
    await seedTag('primo', 'portata');
    await seedTag('secondo', 'portata');
    final id = await repo.create(
      name: 'Ragù',
      ingredients: [DishIngredientDraft(ingredientId: 'carne', qtyBase4: 600)],
      tagIds: ['primo'],
    );

    await repo.update(
      id,
      name: 'Ragù bianco',
      ingredients: [
        DishIngredientDraft(ingredientId: 'carne', qtyBase4: 500),
        DishIngredientDraft(ingredientId: 'sale', qtyBase4: null),
      ],
      tagIds: ['secondo'],
    );

    expect((await repo.getDish(id))!.name, 'Ragù bianco');
    final ings = await repo.getIngredients(id);
    expect(ings.length, 2);
    expect(ings.firstWhere((i) => i.ingredientId == 'carne').qtyBase4, 500);

    final tags = await db.select(db.dishTags).get();
    expect(tags.single.tagId, 'secondo'); // replaced, not accumulated
  });

  test('watchAllWithTags re-emits after local create', () async {
    await seedIngredient('carne');

    final emissions = <List<DishWithTags>>[];
    final sub = repo.watchAllWithTags().listen(emissions.add);
    // Allow initial query to fire.
    await pumpEventQueue();
    expect(emissions, hasLength(1));
    expect(emissions.last, isEmpty);

    // Create a dish — the stream must re-emit with the new dish.
    await repo.create(
      name: 'Carbonara',
      ingredients: [DishIngredientDraft(ingredientId: 'carne', qtyBase4: 400)],
    );
    await pumpEventQueue();
    expect(emissions, hasLength(2));
    expect(emissions.last, hasLength(1));
    expect(emissions.last.first.dish.name, 'Carbonara');

    await sub.cancel();
  });

  test('delete removes dish, rows, tags and plan assignments', () async {
    await seedIngredient('carne');
    await seedTag('primo', 'portata');
    final id = await repo.create(
      name: 'Ragù',
      ingredients: [DishIngredientDraft(ingredientId: 'carne', qtyBase4: 600)],
      tagIds: ['primo'],
    );
    // Assign the dish to an evening.
    final now = DateTime.now().toUtc();
    await db.into(db.weekPlans).insert(WeekPlansCompanion.insert(
        id: 'wp', householdId: householdId, year: 2026, week: 25,
        createdAt: now, updatedAt: now));
    await db.into(db.planDays).insert(PlanDaysCompanion.insert(
        id: 'pd', weekPlanId: 'wp', householdId: householdId,
        dayOfWeek: 1, guests: 4, createdAt: now, updatedAt: now));
    await db.into(db.planDayDishes).insert(PlanDayDishesCompanion.insert(
        id: 'pdd', planDayId: 'pd', dishId: id, householdId: householdId,
        sortOrder: const Value(0), createdAt: now));

    await repo.delete(id);

    expect(await repo.getDish(id), isNull);
    expect(await repo.getIngredients(id), isEmpty);
    expect(await db.select(db.dishTags).get(), isEmpty);
    expect(await db.select(db.planDayDishes).get(), isEmpty);
  });

  test('recipe_url is saved and retrieved', () async {
    await seedIngredient('carne');
    final id = await repo.create(
      name: 'Pasta al forno',
      ingredients: [DishIngredientDraft(ingredientId: 'carne', qtyBase4: 300)],
      recipeUrl: 'https://example.com/pasta',
    );
    final dish = await repo.getDish(id);
    expect(dish!.recipeUrl, 'https://example.com/pasta');

    await repo.update(id,
      name: 'Pasta al forno',
      ingredients: [DishIngredientDraft(ingredientId: 'carne', qtyBase4: 300)],
      recipeUrl: const Value(null),
    );
    final updated = await repo.getDish(id);
    expect(updated!.recipeUrl, isNull);
  });
}
