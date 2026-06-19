import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/ingredient_repository.dart';

/// Regole di gestione del catalogo ingredienti (FR-16/17/18) su schema
/// "stile PowerSync" (senza DEFAULT).
void main() {
  late AppDatabase db;
  late IngredientRepository repo;
  const householdId = 'hh-1';

  Future<void> exec(String sql) => db.customStatement(sql);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await exec('''CREATE TABLE ingredient (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT, unit TEXT,
      is_qb INTEGER, category TEXT, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
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

  group('FR-16 unità bloccata dopo l\'uso', () {
    test('l\'unità è modificabile finché non è usato', () async {
      final ing = await repo.create(name: 'Latte', unit: 'ml');
      await repo.update(ing.id, name: 'Latte', unit: 'l');
      final updated = await repo.watchAll().first;
      expect(updated.single.unit, 'l');
    });

    test('l\'unità non cambia più dopo l\'uso in un piatto', () async {
      final ing = await repo.create(name: 'Latte', unit: 'ml');
      await seedDish('d1');
      await use('d1', ing.id, 200);

      expect(await repo.isUnitLocked(ing.id), true);
      await repo.update(ing.id, name: 'Latte intero', unit: 'l');
      final updated = await repo.watchAll().first;
      expect(updated.single.name, 'Latte intero'); // nome sì
      expect(updated.single.unit, 'ml'); // unità no
    });
  });

  group('FR-17 eliminazione protetta', () {
    test('non eliminabile se in uso, eliminabile dopo la rimozione', () async {
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

  group('reparto (category)', () {
    test('si salva alla creazione e si legge', () async {
      final ing =
          await repo.create(name: 'Mele', unit: 'g', category: 'Ortofrutta');
      expect(ing.category, 'Ortofrutta');
      expect((await repo.watchAll().first).single.category, 'Ortofrutta');
    });

    test('è sempre modificabile, anche se l\'unità è bloccata', () async {
      final ing = await repo.create(name: 'Latte', unit: 'ml');
      await seedDish('d1');
      await use('d1', ing.id, 200);
      expect(await repo.isUnitLocked(ing.id), true);

      await repo.update(ing.id,
          name: 'Latte', category: const Value('Latticini e uova'));
      expect((await repo.watchAll().first).single.category, 'Latticini e uova');

      // Si può anche azzerare ("Senza reparto").
      await repo.update(ing.id, name: 'Latte', category: const Value(null));
      expect((await repo.watchAll().first).single.category, isNull);
    });
  });

  group('FR-18 unione doppioni', () {
    test('unisce solo a parità di unità', () async {
      final a = await repo.create(name: 'Pomodori', unit: 'g');
      final b = await repo.create(name: 'Pomodoro', unit: 'pz');
      expect(await repo.merge(sourceId: a.id, targetId: b.id), false);
      expect((await repo.watchAll().first).length, 2);
    });

    test('ripunta le righe dei piatti sul target', () async {
      final a = await repo.create(name: 'Pomodori', unit: 'g');
      final b = await repo.create(name: 'Pomodoro', unit: 'g');
      await seedDish('d1');
      await use('d1', a.id, 300);

      expect(await repo.merge(sourceId: a.id, targetId: b.id), true);
      expect((await repo.watchAll().first).single.id, b.id);
      // La riga del piatto ora punta al target con la stessa quantità.
      expect(await repo.usageCount(b.id), 1);
      final rows = await db.select(db.dishIngredients).get();
      expect(rows.single.ingredientId, b.id);
      expect(rows.single.qtyBase4, 300);
    });

    test('somma le quantità quando un piatto usa già il target', () async {
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
