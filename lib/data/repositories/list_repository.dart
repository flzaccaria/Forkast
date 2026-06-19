import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/list_generation.dart';
import '../database.dart';

/// Displayed row of the generated layer, with override and check applied.
class GeneratedItemView {
  GeneratedItemView({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.category,
    required this.generatedQty,
    required this.overrideQty,
    required this.isQb,
    required this.removed,
    required this.hasOverride,
    required this.checked,
  });

  final String ingredientId;
  final String name;
  final String unit;
  final String? category;
  final double? generatedQty;
  final double? overrideQty;
  final bool isQb;
  final bool removed;
  final bool hasOverride;
  final bool checked;

  /// Displayed quantity: the override takes precedence over the generated value.
  double? get displayQty => hasOverride ? overrideQty : generatedQty;
}

/// Displayed manual item, with check applied.
class ManualItemView {
  ManualItemView({
    required this.id,
    required this.name,
    required this.qty,
    required this.unit,
    required this.checked,
  });

  final String id;
  final String name;
  final double? qty;
  final String? unit;
  final bool checked;
}

/// Two-layer shopping list (FR-13/21): snapshot generated from the plan
/// (recreatable) + overrides/manual items/checks (persistent). All filtered
/// by household (ADR-005), client-side UUIDs, local-first writes.
class ListRepository {
  ListRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Automatic list regeneration setting (FR-21), default off: normally it is
  /// the user who decides when to update.
  Future<bool> autoRegen() async {
    final household = await (_db.select(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .getSingle();
    return household.autoRegen;
  }

  Stream<ShoppingList?> watchList(String weekPlanId) {
    return (_db.select(_db.shoppingLists)
          ..where((s) =>
              s.householdId.equals(_householdId) &
              s.weekPlanId.equals(weekPlanId)))
        .watchSingleOrNull();
  }

  // --- Snapshot generation (FR-10/11/12) ------------------------------------

  Future<List<ListLineInput>> _gatherLines(String weekPlanId) async {
    final rows = await _db.customSelect(
      'SELECT di.ingredient_id AS ingredient_id, i.unit AS unit, '
      'i.is_qb AS is_qb, di.qty_base4 AS qty_base4, pd.guests AS guests '
      'FROM plan_day pd '
      'JOIN plan_day_dish pdd ON pdd.plan_day_id = pd.id '
      'JOIN dish_ingredient di ON di.dish_id = pdd.dish_id '
      'JOIN ingredient i ON i.id = di.ingredient_id '
      'WHERE pd.week_plan_id = ?',
      variables: [Variable.withString(weekPlanId)],
      readsFrom: {
        _db.planDays,
        _db.planDayDishes,
        _db.dishIngredients,
        _db.ingredients,
      },
    ).get();

    return rows
        .map((r) => ListLineInput(
              ingredientId: r.read<String>('ingredient_id'),
              unit: r.read<String>('unit'),
              isQb: r.read<int>('is_qb') != 0,
              qtyBase4: r.readNullable<double>('qty_base4'),
              guests: r.read<int>('guests'),
            ))
        .toList();
  }

  /// Current plan fingerprint, to detect divergence (FR-21).
  Future<String> currentPlanHash(String weekPlanId) async {
    return planHash(await _gatherLines(weekPlanId));
  }

  /// Generates (or regenerates) the snapshot on an explicit user action,
  /// saving the plan hash. Replaces the generated rows; overrides, manual
  /// items and checks remain (FR-21).
  Future<String> generate(String weekPlanId) async {
    final lines = await _gatherLines(weekPlanId);
    final rows = aggregateList(lines);
    final hash = planHash(lines);
    final now = DateTime.now().toUtc();

    final existing = await (_db.select(_db.shoppingLists)
          ..where((s) =>
              s.householdId.equals(_householdId) &
              s.weekPlanId.equals(weekPlanId)))
        .getSingleOrNull();
    final listId = existing?.id ?? _uuid.v4();

    await _db.transaction(() async {
      if (existing == null) {
        await _db.into(_db.shoppingLists).insert(
              ShoppingListsCompanion.insert(
                id: listId,
                householdId: _householdId,
                weekPlanId: weekPlanId,
                generatedAt: now,
                planHash: hash,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.shoppingLists)
              ..where((s) => s.id.equals(listId)))
            .write(ShoppingListsCompanion(
          generatedAt: Value(now),
          planHash: Value(hash),
          updatedAt: Value(now),
        ));
      }

      await (_db.delete(_db.listGeneratedRows)
            ..where((g) => g.shoppingListId.equals(listId)))
          .go();

      await _db.batch((b) {
        for (final row in rows) {
          b.insert(
            _db.listGeneratedRows,
            ListGeneratedRowsCompanion.insert(
              id: _uuid.v4(),
              shoppingListId: listId,
              ingredientId: row.ingredientId,
              householdId: _householdId,
              qty: Value(row.qty),
              unit: row.unit,
              isQb: Value(row.isQb),
              createdAt: now,
            ),
          );
        }
      });
    });

    return listId;
  }

  // --- Combined reading of the two layers -----------------------------------

  Stream<List<GeneratedItemView>> watchGeneratedItems(String listId) {
    return _db.customSelect(
      'SELECT g.ingredient_id AS ingredient_id, i.name AS name, '
      'g.unit AS unit, i.category AS category, g.qty AS qty, g.is_qb AS is_qb, '
      'o.qty_override AS qty_override, o.removed AS removed, '
      'o.id AS override_id, c.checked AS checked '
      'FROM list_generated_row g '
      'JOIN ingredient i ON i.id = g.ingredient_id '
      'LEFT JOIN list_override o ON o.shopping_list_id = g.shopping_list_id '
      'AND o.ingredient_id = g.ingredient_id '
      'LEFT JOIN list_check c ON c.shopping_list_id = g.shopping_list_id '
      'AND c.ingredient_id = g.ingredient_id '
      'WHERE g.shopping_list_id = ? '
      'ORDER BY i.name',
      variables: [Variable.withString(listId)],
      readsFrom: {
        _db.listGeneratedRows,
        _db.ingredients,
        _db.listOverrides,
        _db.listChecks,
      },
    ).watch().map((rows) {
      return rows.map((r) {
        final hasOverride = r.readNullable<String>('override_id') != null;
        return GeneratedItemView(
          ingredientId: r.read<String>('ingredient_id'),
          name: r.read<String>('name'),
          unit: r.read<String>('unit'),
          category: r.readNullable<String>('category'),
          generatedQty: r.readNullable<double>('qty'),
          overrideQty: r.readNullable<double>('qty_override'),
          isQb: r.read<int>('is_qb') != 0,
          removed: (r.readNullable<int>('removed') ?? 0) != 0,
          hasOverride: hasOverride,
          checked: (r.readNullable<int>('checked') ?? 0) != 0,
        );
      }).toList();
    });
  }

  Stream<List<ManualItemView>> watchManualItems(String listId) {
    return _db.customSelect(
      'SELECT m.id AS id, m.name AS name, m.qty AS qty, m.unit AS unit, '
      'c.checked AS checked '
      'FROM list_manual_item m '
      'LEFT JOIN list_check c ON c.shopping_list_id = m.shopping_list_id '
      'AND c.manual_item_id = m.id '
      'WHERE m.shopping_list_id = ? '
      'ORDER BY m.created_at',
      variables: [Variable.withString(listId)],
      readsFrom: {_db.listManualItems, _db.listChecks},
    ).watch().map((rows) {
      return rows
          .map((r) => ManualItemView(
                id: r.read<String>('id'),
                name: r.read<String>('name'),
                qty: r.readNullable<double>('qty'),
                unit: r.readNullable<String>('unit'),
                checked: (r.readNullable<int>('checked') ?? 0) != 0,
              ))
          .toList();
    });
  }

  // --- Overrides on generated rows (FR-13/21) -------------------------------

  Future<void> _upsertOverride(
    String listId,
    String ingredientId, {
    double? qtyOverride,
    required bool removed,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.listOverrides)
          ..where((o) =>
              o.shoppingListId.equals(listId) &
              o.ingredientId.equals(ingredientId)))
        .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.listOverrides).insert(
            ListOverridesCompanion.insert(
              id: _uuid.v4(),
              shoppingListId: listId,
              ingredientId: ingredientId,
              householdId: _householdId,
              qtyOverride: Value(qtyOverride),
              removed: Value(removed),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.listOverrides)
            ..where((o) => o.id.equals(existing.id)))
          .write(ListOverridesCompanion(
        qtyOverride: Value(qtyOverride),
        removed: Value(removed),
        updatedAt: Value(now),
      ));
    }
  }

  Future<void> setOverrideQty(
          String listId, String ingredientId, double qty) =>
      _upsertOverride(listId, ingredientId, qtyOverride: qty, removed: false);

  Future<void> removeGeneratedRow(String listId, String ingredientId) =>
      _upsertOverride(listId, ingredientId, qtyOverride: null, removed: true);

  /// Restores a generated row to its computed value, deleting the override.
  Future<void> restoreGeneratedRow(String listId, String ingredientId) {
    return (_db.delete(_db.listOverrides)
          ..where((o) =>
              o.shoppingListId.equals(listId) &
              o.ingredientId.equals(ingredientId)))
        .go();
  }

  // --- Manual items (FR-13) -------------------------------------------------

  Future<void> addManualItem(
    String listId, {
    required String name,
    double? qty,
    String? unit,
  }) {
    final now = DateTime.now().toUtc();
    return _db.into(_db.listManualItems).insert(
          ListManualItemsCompanion.insert(
            id: _uuid.v4(),
            shoppingListId: listId,
            householdId: _householdId,
            name: name,
            qty: Value(qty),
            unit: Value(unit),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> removeManualItem(String listId, String manualItemId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.listChecks)
            ..where((c) =>
                c.shoppingListId.equals(listId) &
                c.manualItemId.equals(manualItemId)))
          .go();
      await (_db.delete(_db.listManualItems)
            ..where((m) => m.id.equals(manualItemId)))
          .go();
    });
  }

  // --- Purchase checks, idempotent and persistent (FR-21) -------------------

  Future<void> setIngredientChecked(
      String listId, String ingredientId, bool checked) async {
    if (!checked) {
      await (_db.delete(_db.listChecks)
            ..where((c) =>
                c.shoppingListId.equals(listId) &
                c.ingredientId.equals(ingredientId)))
          .go();
      return;
    }
    final existing = await (_db.select(_db.listChecks)
          ..where((c) =>
              c.shoppingListId.equals(listId) &
              c.ingredientId.equals(ingredientId)))
        .getSingleOrNull();
    if (existing != null) return;
    await _db.into(_db.listChecks).insert(
          ListChecksCompanion.insert(
            id: _uuid.v4(),
            shoppingListId: listId,
            ingredientId: Value(ingredientId),
            householdId: _householdId,
            checked: const Value(true),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> setManualChecked(
      String listId, String manualItemId, bool checked) async {
    if (!checked) {
      await (_db.delete(_db.listChecks)
            ..where((c) =>
                c.shoppingListId.equals(listId) &
                c.manualItemId.equals(manualItemId)))
          .go();
      return;
    }
    final existing = await (_db.select(_db.listChecks)
          ..where((c) =>
              c.shoppingListId.equals(listId) &
              c.manualItemId.equals(manualItemId)))
        .getSingleOrNull();
    if (existing != null) return;
    await _db.into(_db.listChecks).insert(
          ListChecksCompanion.insert(
            id: _uuid.v4(),
            shoppingListId: listId,
            manualItemId: Value(manualItemId),
            householdId: _householdId,
            checked: const Value(true),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
