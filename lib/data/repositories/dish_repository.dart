import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// A dish with its resolved tags, for display in the catalog list.
class DishWithTags {
  DishWithTags({required this.dish, required this.tags});

  final Dish dish;
  final List<Tag> tags;
}

/// An ingredient row while editing a dish.
/// `qtyBase4` is null for "quanto basta" ingredients.
class DishIngredientDraft {
  DishIngredientDraft({
    required this.ingredientId,
    required this.qtyBase4,
  });

  final String ingredientId;
  final double? qtyBase4;
}

/// Access to the dish catalog and its ingredient rows.
/// Filtered by household (ADR-005), client-side UUIDs (ADR-003).
class DishRepository {
  DishRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Dish catalog ordered by name, filterable by text, tag, difficulty and
  /// time estimate (FR-15).
  Stream<List<Dish>> watchAll({
    String query = '',
    String? tagId,
    String? difficulty,
    String? timeEstimate,
  }) {
    final q = _db.select(_db.dishes)
      ..where((d) => d.householdId.equals(_householdId))
      ..orderBy([(d) => OrderingTerm(expression: d.name)]);
    if (query.trim().isNotEmpty) {
      q.where((d) => d.name.lower().contains(query.trim().toLowerCase()));
    }
    if (tagId != null) {
      final tagged = _db.selectOnly(_db.dishTags)
        ..addColumns([_db.dishTags.dishId])
        ..where(_db.dishTags.tagId.equals(tagId));
      q.where((d) => d.id.isInQuery(tagged));
    }
    if (difficulty != null) {
      q.where((d) => d.difficulty.equals(difficulty));
    }
    if (timeEstimate != null) {
      q.where((d) => d.timeEstimate.equals(timeEstimate));
    }
    return q.watch();
  }

  /// Dishes with their resolved tags for the catalog list view.
  Stream<List<DishWithTags>> watchAllWithTags({
    String query = '',
    String? tagId,
    String? difficulty,
    String? timeEstimate,
  }) {
    final dishStream = watchAll(
      query: query,
      tagId: tagId,
      difficulty: difficulty,
      timeEstimate: timeEstimate,
    );
    final tagTable = _db.tags;
    final dtTable = _db.dishTags;
    final allTagsStream = (_db.select(dtTable).join([
      innerJoin(tagTable, tagTable.id.equalsExp(dtTable.tagId)),
    ])
          ..where(dtTable.householdId.equals(_householdId)))
        .watch()
        .map((rows) {
      final map = <String, List<Tag>>{};
      for (final row in rows) {
        final dt = row.readTable(dtTable);
        final tag = row.readTable(tagTable);
        (map[dt.dishId] ??= []).add(tag);
      }
      return map;
    });
    return dishStream.asyncExpand((dishes) {
      return allTagsStream.map((tagMap) {
        return dishes.map((dish) {
          return DishWithTags(
            dish: dish,
            tags: tagMap[dish.id] ?? const [],
          );
        }).toList();
      });
    });
  }

  /// Ingredient rows of a dish.
  Stream<List<DishIngredient>> watchIngredients(String dishId) {
    return (_db.select(_db.dishIngredients)
          ..where((di) => di.dishId.equals(dishId)))
        .watch();
  }

  /// One-time read of the dish (to preload the editor).
  Future<Dish?> getDish(String dishId) {
    return (_db.select(_db.dishes)..where((d) => d.id.equals(dishId)))
        .getSingleOrNull();
  }

  /// One-time read of the ingredient rows (to preload the editor).
  Future<List<DishIngredient>> getIngredients(String dishId) {
    return (_db.select(_db.dishIngredients)
          ..where((di) => di.dishId.equals(dishId)))
        .get();
  }

  /// Creates a dish with its ingredient rows and tags in a single
  /// transaction. `tagIds` gathers the portata (at most one) and attributes (FR-14).
  Future<String> create({
    required String name,
    required List<DishIngredientDraft> ingredients,
    List<String> tagIds = const [],
    String? difficulty,
    String? timeEstimate,
  }) async {
    final now = DateTime.now().toUtc();
    final dishId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.dishes).insert(
            DishesCompanion.insert(
              id: dishId,
              householdId: _householdId,
              name: name,
              difficulty: Value(difficulty),
              timeEstimate: Value(timeEstimate),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.batch((b) {
        for (final ing in ingredients) {
          b.insert(
            _db.dishIngredients,
            DishIngredientsCompanion.insert(
              id: _uuid.v4(),
              dishId: dishId,
              ingredientId: ing.ingredientId,
              householdId: _householdId,
              qtyBase4: Value(ing.qtyBase4),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
        for (final tagId in tagIds) {
          b.insert(
            _db.dishTags,
            DishTagsCompanion.insert(
              id: _uuid.v4(),
              dishId: dishId,
              tagId: tagId,
              householdId: _householdId,
              createdAt: now,
            ),
          );
        }
      });
    });

    return dishId;
  }

  /// Updates an existing dish: name, ingredient rows and tags are fully
  /// rewritten in a single transaction. The row IDs are regenerated (the list
  /// layer is a derived snapshot, it regenerates).
  Future<void> update(
    String dishId, {
    required String name,
    required List<DishIngredientDraft> ingredients,
    List<String> tagIds = const [],
    Value<String?> difficulty = const Value.absent(),
    Value<String?> timeEstimate = const Value.absent(),
  }) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.dishes)..where((d) => d.id.equals(dishId))).write(
          DishesCompanion(
            name: Value(name),
            difficulty: difficulty,
            timeEstimate: timeEstimate,
            updatedAt: Value(now),
          ));
      await (_db.delete(_db.dishIngredients)
            ..where((di) => di.dishId.equals(dishId)))
          .go();
      await (_db.delete(_db.dishTags)..where((dt) => dt.dishId.equals(dishId)))
          .go();
      await _db.batch((b) {
        for (final ing in ingredients) {
          b.insert(
            _db.dishIngredients,
            DishIngredientsCompanion.insert(
              id: _uuid.v4(),
              dishId: dishId,
              ingredientId: ing.ingredientId,
              householdId: _householdId,
              qtyBase4: Value(ing.qtyBase4),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
        for (final tagId in tagIds) {
          b.insert(
            _db.dishTags,
            DishTagsCompanion.insert(
              id: _uuid.v4(),
              dishId: dishId,
              tagId: tagId,
              householdId: _householdId,
              createdAt: now,
            ),
          );
        }
      });
    });
  }

  /// Number of planned dinners that include this dish (plan_day_dish rows).
  Future<int> plannedDinnerCount(String dishId) async {
    final count = _db.planDayDishes.id.count();
    final query = _db.selectOnly(_db.planDayDishes)
      ..addColumns([count])
      ..where(_db.planDayDishes.dishId.equals(dishId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Deletes a dish and its links: ingredient rows, tags and plan
  /// assignments (plan_day_dish). The list layer is derived and regenerates,
  /// so it is not touched here.
  Future<void> delete(String dishId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.dishIngredients)
            ..where((di) => di.dishId.equals(dishId)))
          .go();
      await (_db.delete(_db.dishTags)..where((dt) => dt.dishId.equals(dishId)))
          .go();
      await (_db.delete(_db.planDayDishes)
            ..where((p) => p.dishId.equals(dishId)))
          .go();
      await (_db.delete(_db.dishes)..where((d) => d.id.equals(dishId))).go();
    });
  }
}
