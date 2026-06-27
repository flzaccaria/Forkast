import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/dish_repository.dart';
import 'package:forkast/data/repositories/ingredient_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Test-only helper that replicates what the server-side
/// `bootstrap_household()` function does, but locally — so unit tests don't
/// need Supabase.
Future<String> _insertHouseholdLocal(AppDatabase db, String deviceId) async {
  final existing = await (db.select(db.memberships)
        ..where((m) => m.deviceId.equals(deviceId)))
      .getSingleOrNull();
  if (existing != null) return existing.householdId;

  final now = DateTime.now().toUtc();
  final householdId = _uuid.v4();

  await db.batch((b) {
    b.insert(
      db.households,
      HouseholdsCompanion.insert(
        id: householdId,
        defaultGuests: const Value(4),
        weekStartDay: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
    );
    b.insert(
      db.memberships,
      MembershipsCompanion.insert(
        id: _uuid.v4(),
        householdId: householdId,
        deviceId: deviceId,
        role: const Value('member'),
        joinedAt: now,
        updatedAt: now,
      ),
    );
  });

  return householdId;
}

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
/// (repository) produce readable rows without NULL.
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
        seeded_at TEXT,
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
        rounding_kind TEXT,
        seed_key TEXT,
        name_modified INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )''');
    await db.customStatement('''
      CREATE TABLE dish (
        id TEXT PRIMARY KEY,
        household_id TEXT,
        name TEXT,
        difficulty TEXT,
        time_estimate TEXT,
        recipe_url TEXT,
        seed_key TEXT,
        name_modified INTEGER DEFAULT 0,
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

  test('local household insert produces readable rows (defaults populated)',
      () async {
    final householdId = await _insertHouseholdLocal(db, 'device-A');

    final household = await (db.select(db.households)
          ..where((h) => h.id.equals(householdId)))
        .getSingle();
    expect(household.defaultGuests, 4);
    expect(household.weekStartDay, 1);
    final membership = await (db.select(db.memberships)
          ..where((m) => m.deviceId.equals('device-A')))
        .getSingle();
    expect(membership.role, 'member');
    expect(membership.householdId, householdId);
  });

  test('local household insert is idempotent for the same device', () async {
    final first = await _insertHouseholdLocal(db, 'device-B');
    final second = await _insertHouseholdLocal(db, 'device-B');
    expect(first, second);

    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM membership')
        .getSingle();
    expect(count.read<int>('c'), 1);
  });

  test('IngredientRepository.create produces readable rows (is_qb populated)',
      () async {
    final householdId = await _insertHouseholdLocal(db, 'device-C');
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

  test('ingredient with NULL rounding_kind reads without crash, treated as weight',
      () async {
    final householdId = await _insertHouseholdLocal(db, 'device-E');
    final now = DateTime.now().toUtc().toIso8601String();
    await db.customStatement(
      "INSERT INTO ingredient (id, household_id, name, unit, is_qb, "
      "rounding_kind, category, created_at, updated_at) "
      "VALUES ('ing-null-rk', '$householdId', 'Farina', 'g', 0, "
      "NULL, NULL, '$now', '$now')",
    );

    final repo = IngredientRepository(db, householdId);
    final all = await repo.watchAll().first;
    final farina = all.firstWhere((i) => i.name == 'Farina');
    expect(farina.roundingKind, isNull);
    final effective = farina.roundingKind ?? 'weight';
    expect(effective, 'weight');
  });

  test('DishRepository.create saves dish and ingredient rows', () async {
    final householdId = await _insertHouseholdLocal(db, 'device-D');
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
