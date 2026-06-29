import 'dart:async';

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
    this.seedKey,
    this.nameModified = false,
    this.isRecurring = false,
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
  final String? seedKey;
  final bool nameModified;
  final bool isRecurring;

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

  Stream<ShoppingList?> watchList(String weekPlanId) {
    return (_db.select(_db.shoppingLists)
          ..where((s) =>
              s.householdId.equals(_householdId) &
              s.weekPlanId.equals(weekPlanId)))
        .watchSingleOrNull();
  }

  // --- Snapshot generation (FR-10/11/12) ------------------------------------

  static const _gatherLinesSql =
      'SELECT di.ingredient_id AS ingredient_id, i.unit AS unit, '
      'i.rounding_kind AS rounding_kind, '
      'i.is_qb AS is_qb, di.qty_base4 AS qty_base4, pd.guests AS guests '
      'FROM plan_day pd '
      'JOIN plan_day_dish pdd ON pdd.plan_day_id = pd.id '
      'JOIN dish_ingredient di ON di.dish_id = pdd.dish_id '
      'JOIN ingredient i ON i.id = di.ingredient_id '
      'WHERE pd.week_plan_id = ?';

  Set<ResultSetImplementation> get _gatherLinesReadsFrom => {
        _db.planDays,
        _db.planDayDishes,
        _db.dishIngredients,
        _db.ingredients,
      };

  static ListLineInput _rowToLineInput(QueryRow r) => ListLineInput(
        ingredientId: r.read<String>('ingredient_id'),
        unit: r.read<String>('unit'),
        roundingKind: r.readNullable<String>('rounding_kind') ?? 'weight',
        isQb: r.read<int>('is_qb') != 0,
        qtyBase4: r.readNullable<double>('qty_base4'),
        guests: r.read<int>('guests'),
      );

  Future<List<ListLineInput>> _gatherLines(String weekPlanId) async {
    final rows = await _db
        .customSelect(
          _gatherLinesSql,
          variables: [Variable.withString(weekPlanId)],
          readsFrom: _gatherLinesReadsFrom,
        )
        .get();
    return rows.map(_rowToLineInput).toList();
  }

  // --- Recurring ingredients (FR-28) ----------------------------------------

  Future<List<ListLineInput>> _gatherRecurringLines(String? listId) async {
    final recurring = await (_db.select(_db.ingredients)
          ..where((i) =>
              i.householdId.equals(_householdId) & i.alwaysInList.equals(true)))
        .get();
    if (recurring.isEmpty) return const [];

    final excluded = <String>{};
    if (listId != null) {
      final exclusions = await (_db.select(_db.listRecurringExclusions)
            ..where((e) => e.shoppingListId.equals(listId)))
          .get();
      excluded.addAll(exclusions.map((e) => e.ingredientId));
    }

    return recurring
        .where((i) => !excluded.contains(i.id))
        .map((i) => ListLineInput(
              ingredientId: i.id,
              unit: i.unit,
              roundingKind: i.roundingKind ?? 'weight',
              isQb: i.isQb,
              qtyBase4: i.isQb ? null : i.defaultQty,
              guests: 4,
            ))
        .toList();
  }

  String _combinedHash(
      List<ListLineInput> planLines, List<ListLineInput> recurringLines) {
    final p = planHash(planLines);
    final r = planHash(recurringLines);
    return _fnv1a64Pair(p, r);
  }

  static String _fnv1a64Pair(String a, String b) {
    final s = '$a|$b';
    final mask = (BigInt.one << 64) - BigInt.one;
    var hash = BigInt.parse('14695981039346656037');
    final prime = BigInt.parse('1099511628211');
    for (final unit in s.codeUnits) {
      hash = (hash ^ BigInt.from(unit)) & mask;
      hash = (hash * prime) & mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  /// Current plan fingerprint, to detect divergence (FR-21).
  /// Includes both plan-derived and recurring ingredient lines.
  Future<String> currentPlanHash(String weekPlanId,
      {String? listId}) async {
    final planLines = await _gatherLines(weekPlanId);
    final recurringLines = await _gatherRecurringLines(listId);
    return _combinedHash(planLines, recurringLines);
  }

  /// Reactive plan fingerprint: re-emits whenever the plan tables or
  /// recurring ingredient configuration changes. Used by the list screen
  /// to trigger automatic regeneration (FR-21 v0.6, FR-28).
  Stream<String> watchPlanHash(String weekPlanId, {String? listId}) {
    final planStream = _db
        .customSelect(
          _gatherLinesSql,
          variables: [Variable.withString(weekPlanId)],
          readsFrom: _gatherLinesReadsFrom,
        )
        .watch()
        .map((rows) => rows.map(_rowToLineInput).toList());

    final recurringStream = (_db.select(_db.ingredients)
          ..where((i) =>
              i.householdId.equals(_householdId) &
              i.alwaysInList.equals(true)))
        .watch();

    List<ListLineInput>? lastPlanLines;
    List<Ingredient>? lastRecurring;

    String computeHash() {
      final pl = lastPlanLines ?? const [];
      final rl = (lastRecurring ?? const [])
          .map((i) => ListLineInput(
                ingredientId: i.id,
                unit: i.unit,
                roundingKind: i.roundingKind ?? 'weight',
                isQb: i.isQb,
                qtyBase4: i.isQb ? null : i.defaultQty,
                guests: 4,
              ))
          .toList();
      return _combinedHash(pl, rl);
    }

    late StreamController<String> controller;
    StreamSubscription<List<ListLineInput>>? planSub;
    StreamSubscription<List<Ingredient>>? recurringSub;

    controller = StreamController<String>(
      onListen: () {
        planSub = planStream.listen((lines) {
          lastPlanLines = lines;
          if (lastRecurring != null) controller.add(computeHash());
        }, onError: controller.addError);
        recurringSub = recurringStream.listen((ingredients) {
          lastRecurring = ingredients;
          if (lastPlanLines != null) controller.add(computeHash());
        }, onError: controller.addError);
      },
      onCancel: () {
        planSub?.cancel();
        recurringSub?.cancel();
      },
    );
    return controller.stream;
  }

  /// Generates (or regenerates) the snapshot on an explicit user action,
  /// saving the plan hash. Replaces the generated rows; overrides, manual
  /// items and checks remain (FR-21). Recurring ingredients (FR-28) are
  /// included automatically and aggregated with plan-derived quantities.
  Future<String> generate(String weekPlanId) async {
    final existing = await (_db.select(_db.shoppingLists)
          ..where((s) =>
              s.householdId.equals(_householdId) &
              s.weekPlanId.equals(weekPlanId)))
        .getSingleOrNull();
    final listId = existing?.id ?? _uuid.v4();

    final planLines = await _gatherLines(weekPlanId);
    final recurringLines = await _gatherRecurringLines(existing?.id);
    final allLines = [...planLines, ...recurringLines];
    final rows = aggregateList(allLines);
    final hash = _combinedHash(planLines, recurringLines);
    final now = DateTime.now().toUtc();

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
      'i.seed_key AS seed_key, i.name_modified AS name_modified, '
      'i.always_in_list AS always_in_list, '
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
          seedKey: r.readNullable<String>('seed_key'),
          nameModified: (r.readNullable<int>('name_modified') ?? 0) != 0,
          isRecurring: (r.readNullable<int>('always_in_list') ?? 0) != 0,
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

  // --- Purchase check reset (FR-31) -----------------------------------------

  /// Clears all purchase checks for the given shopping list, preserving
  /// generated rows, overrides, and manual items.
  Future<void> resetChecks(String listId) {
    return (_db.delete(_db.listChecks)
          ..where((c) => c.shoppingListId.equals(listId)))
        .go();
  }

  // --- Recurring exclusions (FR-29) ------------------------------------------

  /// Excludes a recurring ingredient from the current week's list.
  Future<void> excludeRecurring(String listId, String ingredientId) async {
    final now = DateTime.now().toUtc();
    await _db.into(_db.listRecurringExclusions).insert(
          ListRecurringExclusionsCompanion.insert(
            id: _uuid.v4(),
            shoppingListId: listId,
            ingredientId: ingredientId,
            householdId: _householdId,
            createdAt: now,
          ),
        );
  }

  /// Re-includes a previously excluded recurring ingredient.
  Future<void> includeRecurring(String listId, String ingredientId) {
    return (_db.delete(_db.listRecurringExclusions)
          ..where((e) =>
              e.shoppingListId.equals(listId) &
              e.ingredientId.equals(ingredientId)))
        .go();
  }
}
