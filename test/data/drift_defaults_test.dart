import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/bootstrap.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/dish_repository.dart';
import 'package:forkast/data/repositories/ingredient_repository.dart';

/// Regression test for the "unapplied drift defaults" class of bug.
///
/// In production it is PowerSync that creates the SQLite schema, NOT drift: the
/// `withDefault(...)` defined in the drift tables never end up in the DB.
/// If an insert relies on the default instead of passing the explicit value,
/// the column stays NULL and drift crashes in the mapping ("Null check operator
/// used on a null value").
///
/// Here we replicate that condition: we create the tables WITHOUT DEFAULT
/// clauses (as PowerSync does) and verify that the real inserts
/// (bootstrap + repository) produce readable rows without NULL.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // "PowerSync-style" schema: no DEFAULT, no NOT NULL on the non-id
    // fields. If the code relied on drift defaults, the columns
    // would stay NULL and the read would fail.
    await db.customStatement('''
      CREATE TABLE household (
        id TEXT PRIMARY KEY,
        name TEXT,
        default_guests INTEGER,
        week_start_day INTEGER,
        auto_regen INTEGER,
        created_at TEXT,
        updated_at TEXT
      )''');
    await db.customStatement('''
      CREATE TABLE membership (
        id TEXT PRIMARY KEY,
        household_id TEXT,
        device_id TEXT,
        role TEXT,
        joined_at TEXT,
        updated_at TEXT
      )''');
    await db.customStatement('''
      CREATE TABLE ingredient (
        id TEXT PRIMARY KEY,
        household_id TEXT,
        name TEXT,
        unit TEXT,
        is_qb INTEGER,
        category TEXT,
        created_at TEXT,
        updated_at TEXT
      )''');
    await db.customStatement('''
      CREATE TABLE dish (
        id TEXT PRIMARY KEY,
        household_id TEXT,
        name TEXT,
        created_at TEXT,
        updated_at TEXT
      )''');
    await db.customStatement('''
      CREATE TABLE dish_ingredient (
        id TEXT PRIMARY KEY,
        dish_id TEXT,
        ingredient_id TEXT,
        household_id TEXT,
        qty_base4 REAL,
        created_at TEXT,
        updated_at TEXT
      )''');
  });

  tearDown(() async {
    await db.close();
  });

  test('ensureHousehold creates readable household + membership (defaults populated)',
      () async {
    final householdId = await ensureHousehold(db, 'device-A');

    // The read must not crash: the fields with defaults are populated.
    final household = await (db.select(db.households)
          ..where((h) => h.id.equals(householdId)))
        .getSingle();
    expect(household.defaultGuests, 4);
    expect(household.weekStartDay, 1);
    expect(household.autoRegen, false);

    final membership = await (db.select(db.memberships)
          ..where((m) => m.deviceId.equals('device-A')))
        .getSingle();
    expect(membership.role, 'member');
    expect(membership.householdId, householdId);
  });

  test('ensureHousehold is idempotent for the same device', () async {
    final first = await ensureHousehold(db, 'device-B');
    final second = await ensureHousehold(db, 'device-B');
    expect(first, second);

    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM membership')
        .getSingle();
    expect(count.read<int>('c'), 1);
  });

  test('IngredientRepository.create produces readable rows (is_qb populated)',
      () async {
    final householdId = await ensureHousehold(db, 'device-C');
    final repo = IngredientRepository(db, householdId);

    await repo.create(name: 'Pasta', unit: 'g');
    await repo.create(name: 'Sale', unit: 'g', isQb: true);

    final all = await repo.watchAll().first;
    expect(all.map((i) => i.name), containsAll(['Pasta', 'Sale']));
    final sale = all.firstWhere((i) => i.name == 'Sale');
    final pasta = all.firstWhere((i) => i.name == 'Pasta');
    expect(sale.isQb, true);
    expect(pasta.isQb, false);
  });

  test('DishRepository.create saves dish and ingredient rows', () async {
    final householdId = await ensureHousehold(db, 'device-D');
    final ingredientRepo = IngredientRepository(db, householdId);
    final dishRepo = DishRepository(db, householdId);

    await ingredientRepo.create(name: 'Pomodoro', unit: 'g');
    final ingredients = await ingredientRepo.watchAll().first;
    final pomodoro = ingredients.firstWhere((i) => i.name == 'Pomodoro');

    final dishId = await dishRepo.create(
      name: 'Sugo',
      ingredients: [
        DishIngredientDraft(ingredientId: pomodoro.id, qtyBase4: 400),
      ],
    );

    final dishes = await dishRepo.watchAll().first;
    expect(dishes.single.name, 'Sugo');

    final rows = await dishRepo.watchIngredients(dishId).first;
    expect(rows.single.ingredientId, pomodoro.id);
    expect(rows.single.qtyBase4, 400);
  });
}
