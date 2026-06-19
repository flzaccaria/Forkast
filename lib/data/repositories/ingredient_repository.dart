import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// Accesso al catalogo ingredienti, sempre filtrato per household (ADR-005).
/// Scritture local-first con UUID generati dal client (ADR-003).
class IngredientRepository {
  IngredientRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Stream del catalogo, ordinato per nome. Si aggiorna a ogni scrittura
  /// locale o sync in arrivo.
  Stream<List<Ingredient>> watchAll() {
    return (_db.select(_db.ingredients)
          ..where((i) => i.householdId.equals(_householdId))
          ..orderBy([(i) => OrderingTerm(expression: i.name)]))
        .watch();
  }

  /// Crea una voce di catalogo e restituisce l'ingrediente inserito, così che
  /// chi crea "al volo" (es. dall'editor piatto) possa selezionarlo subito.
  Future<Ingredient> create({
    required String name,
    required String unit,
    bool isQb = false,
    String? category,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.ingredients).insert(
          IngredientsCompanion.insert(
            id: id,
            householdId: _householdId,
            name: name,
            unit: unit,
            isQb: Value(isQb),
            category: Value(category),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return Ingredient(
      id: id,
      householdId: _householdId,
      name: name,
      unit: unit,
      isQb: isQb,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Numero di piatti che usano l'ingrediente. Base per FR-16/17.
  Future<int> usageCount(String ingredientId) async {
    final count = _db.dishIngredients.id.count();
    final query = _db.selectOnly(_db.dishIngredients)
      ..addColumns([count])
      ..where(_db.dishIngredients.ingredientId.equals(ingredientId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Nomi dei piatti in cui l'ingrediente è usato (FR-17: "mostra dove").
  Future<List<String>> dishesUsing(String ingredientId) async {
    final di = _db.dishIngredients;
    final dish = _db.dishes;
    final query = _db.select(di).join([
      innerJoin(dish, dish.id.equalsExp(di.dishId)),
    ])
      ..where(di.ingredientId.equals(ingredientId))
      ..orderBy([OrderingTerm(expression: dish.name)]);
    final rows = await query.get();
    return rows.map((r) => r.readTable(dish).name).toList();
  }

  /// Aggiorna nome e — solo se non ancora in uso — unità (FR-16). L'unità
  /// passata viene ignorata quando l'ingrediente è già usato in un piatto.
  Future<void> update(
    String ingredientId, {
    required String name,
    String? unit,
    bool? isQb,
    Value<String?> category = const Value.absent(),
  }) async {
    final locked = await usageCount(ingredientId) > 0;
    // L'unità (e il flag q.b., che ne è il corrispettivo) restano immutabili
    // una volta che l'ingrediente è in uso (FR-16). Il reparto, invece, resta
    // sempre modificabile: non incide su quantità/aggregazione.
    final patch = IngredientsCompanion(
      name: Value(name),
      unit: (locked || unit == null) ? const Value.absent() : Value(unit),
      isQb: (locked || isQb == null) ? const Value.absent() : Value(isQb),
      category: category,
      updatedAt: Value(DateTime.now().toUtc()),
    );
    await (_db.update(_db.ingredients)
          ..where((i) => i.id.equals(ingredientId)))
        .write(patch);
  }

  /// L'unità è bloccata quando l'ingrediente è usato (FR-16).
  Future<bool> isUnitLocked(String ingredientId) async =>
      await usageCount(ingredientId) > 0;

  /// Elimina un ingrediente solo se non è usato in alcun piatto (FR-17).
  /// Restituisce false se è ancora in uso.
  Future<bool> deleteIfUnused(String ingredientId) async {
    if (await usageCount(ingredientId) > 0) return false;
    await (_db.delete(_db.ingredients)..where((i) => i.id.equals(ingredientId)))
        .go();
    return true;
  }

  /// Unisce il doppione `sourceId` in `targetId` (FR-18). Consentito solo a
  /// parità di unità di misura. Ogni riga di piatto che usa la sorgente viene
  /// ripuntata sul target; se il piatto usa già il target, le quantità si
  /// sommano e la riga sorgente è eliminata. Infine la sorgente è rimossa dal
  /// catalogo. Restituisce false se le unità differiscono.
  Future<bool> merge({required String sourceId, required String targetId}) async {
    if (sourceId == targetId) return true;
    final source = await (_db.select(_db.ingredients)
          ..where((i) => i.id.equals(sourceId)))
        .getSingleOrNull();
    final target = await (_db.select(_db.ingredients)
          ..where((i) => i.id.equals(targetId)))
        .getSingleOrNull();
    if (source == null || target == null) return false;
    if (source.unit != target.unit || source.isQb != target.isQb) return false;

    await _db.transaction(() async {
      final sourceRows = await (_db.select(_db.dishIngredients)
            ..where((di) => di.ingredientId.equals(sourceId)))
          .get();
      for (final row in sourceRows) {
        final existing = await (_db.select(_db.dishIngredients)
              ..where((di) =>
                  di.dishId.equals(row.dishId) &
                  di.ingredientId.equals(targetId)))
            .getSingleOrNull();
        if (existing == null) {
          await (_db.update(_db.dishIngredients)
                ..where((di) => di.id.equals(row.id)))
              .write(DishIngredientsCompanion(
            ingredientId: Value(targetId),
            qtyBase4: Value(source.isQb ? null : row.qtyBase4),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
        } else {
          // Il piatto usa già il target: somma le quantità (q.b. resta null).
          final merged = source.isQb
              ? null
              : (existing.qtyBase4 ?? 0) + (row.qtyBase4 ?? 0);
          await (_db.update(_db.dishIngredients)
                ..where((di) => di.id.equals(existing.id)))
              .write(DishIngredientsCompanion(
            qtyBase4: Value(merged),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
          await (_db.delete(_db.dishIngredients)
                ..where((di) => di.id.equals(row.id)))
              .go();
        }
      }
      await (_db.delete(_db.ingredients)..where((i) => i.id.equals(sourceId)))
          .go();
    });
    return true;
  }
}
