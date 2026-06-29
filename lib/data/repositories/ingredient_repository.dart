import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/unit.dart';
import '../database.dart';

class IngredientWithUsage {
  IngredientWithUsage(this.ingredient, this.usageCount);

  final Ingredient ingredient;
  final int usageCount;
}

/// Access to the ingredient catalog, always filtered by household (ADR-005).
/// Local-first writes with client-generated UUIDs (ADR-003).
class IngredientRepository {
  IngredientRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Stream of the catalog, ordered by name. Updates on every local write
  /// or incoming sync.
  Stream<List<Ingredient>> watchAll() {
    return (_db.select(_db.ingredients)
          ..where((i) => i.householdId.equals(_householdId))
          ..orderBy([(i) => OrderingTerm(expression: i.name)]))
        .watch();
  }

  /// Stream of ingredients paired with their dish-usage count.
  Stream<List<IngredientWithUsage>> watchAllWithUsage() {
    final ing = _db.ingredients;
    final di = _db.dishIngredients;
    final cnt = di.id.count();

    final query = _db.select(ing).join([
      leftOuterJoin(di, di.ingredientId.equalsExp(ing.id)),
    ])
      ..where(ing.householdId.equals(_householdId))
      ..groupBy([ing.id])
      ..addColumns([cnt])
      ..orderBy([OrderingTerm(expression: ing.name)]);

    return query.watch().map((rows) => rows.map((row) {
          final ingredient = row.readTable(ing);
          final usageCount = row.read(cnt) ?? 0;
          return IngredientWithUsage(ingredient, usageCount);
        }).toList());
  }

  /// Creates a catalog entry and returns the inserted ingredient, so that
  /// whoever creates it "on the fly" (e.g. from the dish editor) can select
  /// it immediately.
  Future<Ingredient> create({
    required String name,
    required String unit,
    bool isQb = false,
    String? category,
    String roundingKind = 'weight',
    bool alwaysInList = false,
    double? defaultQty,
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
            roundingKind: Value(roundingKind),
            nameModified: const Value(false),
            alwaysInList: Value(alwaysInList),
            defaultQty: Value(defaultQty),
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
      roundingKind: roundingKind,
      seedKey: null,
      nameModified: false,
      alwaysInList: alwaysInList,
      defaultQty: defaultQty,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Number of dishes that use the ingredient. Basis for FR-16/17.
  Future<int> usageCount(String ingredientId) async {
    final count = _db.dishIngredients.id.count();
    final query = _db.selectOnly(_db.dishIngredients)
      ..addColumns([count])
      ..where(_db.dishIngredients.ingredientId.equals(ingredientId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Names of the dishes in which the ingredient is used (FR-17: "show where").
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

  /// Updates name and — only if not yet in use — unit (FR-16). The passed
  /// unit is ignored when the ingredient is already used in a dish.
  Future<void> update(
    String ingredientId, {
    required String name,
    String? unit,
    bool? isQb,
    String? roundingKind,
    Value<String?> category = const Value.absent(),
    Value<bool> alwaysInList = const Value.absent(),
    Value<double?> defaultQty = const Value.absent(),
  }) async {
    final locked = await usageCount(ingredientId) > 0;

    // L2: detect name change on a seeded entry → set nameModified.
    Value<bool> nameModifiedPatch = const Value.absent();
    final existing = await (_db.select(_db.ingredients)
          ..where((i) => i.id.equals(ingredientId)))
        .getSingleOrNull();
    if (existing != null && existing.seedKey != null && existing.name != name) {
      nameModifiedPatch = const Value(true);
    }

    final patch = IngredientsCompanion(
      name: Value(name),
      unit: (locked || unit == null) ? const Value.absent() : Value(unit),
      isQb: (locked || isQb == null) ? const Value.absent() : Value(isQb),
      roundingKind: (locked || roundingKind == null)
          ? const Value.absent()
          : Value(roundingKind),
      category: category,
      nameModified: nameModifiedPatch,
      alwaysInList: alwaysInList,
      defaultQty: defaultQty,
      updatedAt: Value(DateTime.now().toUtc()),
    );
    await (_db.update(_db.ingredients)
          ..where((i) => i.id.equals(ingredientId)))
        .write(patch);
  }

  /// Updates the "always in list" flag and optional default quantity (FR-28).
  Future<void> setAlwaysInList(
    String ingredientId, {
    required bool alwaysInList,
    double? defaultQty,
  }) async {
    await (_db.update(_db.ingredients)
          ..where((i) => i.id.equals(ingredientId)))
        .write(IngredientsCompanion(
      alwaysInList: Value(alwaysInList),
      defaultQty: Value(alwaysInList ? defaultQty : null),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }

  /// Stream of recurring ingredients (always_in_list = true).
  Stream<List<Ingredient>> watchRecurring() {
    return (_db.select(_db.ingredients)
          ..where((i) =>
              i.householdId.equals(_householdId) & i.alwaysInList.equals(true))
          ..orderBy([(i) => OrderingTerm(expression: i.name)]))
        .watch();
  }

  /// The unit is locked when the ingredient is used (FR-16).
  Future<bool> isUnitLocked(String ingredientId) async =>
      await usageCount(ingredientId) > 0;

  /// Deletes an ingredient only if it is not used in any dish (FR-17).
  /// Returns false if it is still in use.
  Future<bool> deleteIfUnused(String ingredientId) async {
    if (await usageCount(ingredientId) > 0) return false;
    await (_db.delete(_db.ingredients)..where((i) => i.id.equals(ingredientId)))
        .go();
    return true;
  }

  /// Migrates free-text unit values to the canonical [Unit] enum (FR-5).
  /// Unrecognized values are logged and mapped to [Unit.pezzo] as a
  /// "da rivedere" fallback — no data is lost, only the unit label changes.
  Future<void> migrateUnitsToEnum() async {
    final all = await (_db.select(_db.ingredients)
          ..where((i) => i.householdId.equals(_householdId)))
        .get();
    final now = DateTime.now().toUtc();
    final updates = <(String id, Unit mapped)>[];
    for (final ing in all) {
      if (ing.isQb) continue;
      final canonical = Unit.tryParse(ing.unit);
      if (canonical != null) continue;
      final mapped = Unit.tryParseLoose(ing.unit);
      if (mapped != null) {
        updates.add((ing.id, mapped));
      } else {
        debugPrint('migrateUnitsToEnum: unrecognized unit "${ing.unit}" '
            'on ingredient "${ing.name}" (${ing.id}) — mapping to "pz"');
        updates.add((ing.id, Unit.pezzo));
      }
    }
    if (updates.isEmpty) return;
    await _db.transaction(() async {
      for (final (id, mapped) in updates) {
        await (_db.update(_db.ingredients)..where((i) => i.id.equals(id)))
            .write(IngredientsCompanion(
          unit: Value(mapped.dbValue),
          roundingKind: Value(mapped.roundingKind),
          updatedAt: Value(now),
        ));
      }
    });
  }

  /// Merges the duplicate `sourceId` into `targetId` (FR-18). Allowed only
  /// with matching units of measure. Every dish row that uses the source is
  /// repointed to the target; if the dish already uses the target, the
  /// quantities are summed and the source row is deleted. Finally the source
  /// is removed from the catalog. Returns false if the units differ.
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
          // The dish already uses the target: sum the quantities (q.b. stays null).
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
