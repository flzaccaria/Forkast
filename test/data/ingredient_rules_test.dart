import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/ingredient_repository.dart';

/// Management rules for the ingredient catalog (FR-16/17/18) on a
/// "PowerSync-style" schema (without DEFAULT).
void main() {
  late AppDatabase db;
  late IngredientRepository repo;
  const householdId = 'hh-1';

  Future<void> exec(String sql) => db.customStatement(sql);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await exec('''CREATE TABLE ingredient (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT, unit TEXT,
      is_qb INTEGER, category TEXT, rounding_kind TEXT,
      seed_key TEXT, name_modified INTEGER DEFAULT 0,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
      difficulty TEXT, time_estimate TEXT,
      seed_key TEXT, name_modified INTEGER DEFAULT 0,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish_ingredient (
      id TEXT PRIMARY KEY, dish_id TEXT, ingredient_id TEXT, household_id TEXT,
      qty_base4 REAL, created_at TEXT, updated_at TEXT)''');
    repo = IngredientRepository(db, householdId);
  });

  tearDown(() async => db.close());

  Future<void> seedDish(String id) async {
    final now = DateTime.now().toUtc();
    await db.into(db.dishes).insert(DishesCompanion.insert(
        id: id, householdId: householdId, name: id, createdAt: now, updatedAt: now));
  }

  Future<void> use(String dishId, String ingredientId, double? qty) async {
    final now = DateTime.now().toUtc();
    await db.into(db.dishIngredients).insert(DishIngredientsCompanion.insert(
          id: 'di-$dishId-$ingredientId',
          dishId: dishId,
          ingredientId: ingredientId,
          householdId: householdId,
          qtyBase4: Value(qty),
          createdAt: now,
          updatedAt: now,
        ));
  }

  group('FR-16 unit locked after use', () {
    test('the unit is modifiable until it is used', () async {
      final ing = await repo.create(name: 'Latte', unit: 'ml');
      await repo.update(ing.id, name: 'Latte', unit: 'l');
      final updated = await repo.watchAll().first;
      expect(updated.single.unit, 'l');
    });

    test('the unit no longer changes after use in a dish', () async {
      final ing = await repo.create(name: 'Latte', unit: 'ml');
      await seedDish('d1');
      await use('d1', ing.id, 200);

      expect(await repo.isUnitLocked(ing.id), true);
      await repo.update(ing.id, name: 'Latte intero', unit: 'l');
      final updated = await repo.watchAll().first;
      expect(updated.single.name, 'Latte intero'); // name yes
      expect(updated.single.unit, 'ml'); // unit no
    });
  });

  group('FR-17 protected deletion', () {
    test('not deletable if in use, deletable after removal', () async {
      final ing = await repo.create(name: 'Carne', unit: 'g');
      await seedDish('d1');
      await use('d1', ing.id, 600);

      expect(await repo.usageCount(ing.id), 1);
      expect(await repo.dishesUsing(ing.id), ['d1']);
      expect(await repo.deleteIfUnused(ing.id), false);

      await (db.delete(db.dishIngredients)
            ..where((di) => di.ingredientId.equals(ing.id)))
          .go();
      expect(await repo.deleteIfUnused(ing.id), true);
      expect(await repo.watchAll().first, isEmpty);
    });
  });

  group('department (category)', () {
    test('is saved at creation and read back', () async {
      final ing =
          await repo.create(name: 'Mele', unit: 'g', category: 'Ortofrutta');
      expect(ing.category, 'Ortofrutta');
      expect((await repo.watchAll().first).single.category, 'Ortofrutta');
    });

    test('is always modifiable, even if the unit is locked', () async {
      final ing = await repo.create(name: 'Latte', unit: 'ml');
      await seedDish('d1');
      await use('d1', ing.id, 200);
      expect(await repo.isUnitLocked(ing.id), true);

      await repo.update(ing.id,
          name: 'Latte', category: const Value('Latticini e uova'));
      expect((await repo.watchAll().first).single.category, 'Latticini e uova');

      // It can also be cleared ("No department").
      await repo.update(ing.id, name: 'Latte', category: const Value(null));
      expect((await repo.watchAll().first).single.category, isNull);
    });
  });

  group('FR-18 merge duplicates', () {
    test('merges only with matching units', () async {
      final a = await repo.create(name: 'Pomodori', unit: 'g');
      final b = await repo.create(name: 'Pomodoro', unit: 'pz');
      expect(await repo.merge(sourceId: a.id, targetId: b.id), false);
      expect((await repo.watchAll().first).length, 2);
    });

    test('repoints the dish rows to the target', () async {
      final a = await repo.create(name: 'Pomodori', unit: 'g');
      final b = await repo.create(name: 'Pomodoro', unit: 'g');
      await seedDish('d1');
      await use('d1', a.id, 300);

      expect(await repo.merge(sourceId: a.id, targetId: b.id), true);
      expect((await repo.watchAll().first).single.id, b.id);
      // The dish row now points to the target with the same quantity.
      expect(await repo.usageCount(b.id), 1);
      final rows = await db.select(db.dishIngredients).get();
      expect(rows.single.ingredientId, b.id);
      expect(rows.single.qtyBase4, 300);
    });

    test('sums the quantities when a dish already uses the target', () async {
      final a = await repo.create(name: 'Pomodori', unit: 'g');
      final b = await repo.create(name: 'Pomodoro', unit: 'g');
      await seedDish('d1');
      await use('d1', a.id, 300);
      await use('d1', b.id, 200);

      expect(await repo.merge(sourceId: a.id, targetId: b.id), true);
      final rows = await db.select(db.dishIngredients).get();
      expect(rows.length, 1);
      expect(rows.single.ingredientId, b.id);
      expect(rows.single.qtyBase4, 500);
    });
  });
}
