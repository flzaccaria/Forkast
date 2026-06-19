import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/bootstrap.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/dish_repository.dart';
import 'package:forkast/data/repositories/ingredient_repository.dart';

/// Test di regressione per la classe di bug "default drift non applicati".
///
/// In produzione è PowerSync a creare lo schema SQLite, NON drift: i
/// `withDefault(...)` definiti nelle tabelle drift non finiscono mai nel DB.
/// Se un insert si affida al default invece di passare il valore esplicito,
/// la colonna resta NULL e drift crasha nel mapping ("Null check operator
/// used on a null value").
///
/// Qui replichiamo quella condizione: creiamo le tabelle SENZA clausole
/// DEFAULT (come fa PowerSync) e verifichiamo che gli insert reali
/// (bootstrap + repository) producano righe leggibili senza NULL.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Schema "stile PowerSync": nessun DEFAULT, nessun NOT NULL sui campi
    // non-id. Se il codice si affidasse ai default di drift, le colonne
    // resterebbero NULL e la lettura fallirebbe.
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

  test('ensureHousehold crea household + membership leggibili (default valorizzati)',
      () async {
    final householdId = await ensureHousehold(db, 'device-A');

    // La lettura non deve crashare: i campi con default sono valorizzati.
    final household = await (db.select(db.households)
          ..where((h) => h.id.equals(householdId)))
        .getSingle();
    expect(household.defaultGuests, 4);
    expect(household.weekStartDay, 0);
    expect(household.autoRegen, false);

    final membership = await (db.select(db.memberships)
          ..where((m) => m.deviceId.equals('device-A')))
        .getSingle();
    expect(membership.role, 'member');
    expect(membership.householdId, householdId);
  });

  test('ensureHousehold è idempotente per lo stesso device', () async {
    final first = await ensureHousehold(db, 'device-B');
    final second = await ensureHousehold(db, 'device-B');
    expect(first, second);

    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM membership')
        .getSingle();
    expect(count.read<int>('c'), 1);
  });

  test('IngredientRepository.create produce righe leggibili (is_qb valorizzato)',
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

  test('DishRepository.create salva piatto e righe ingrediente', () async {
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
