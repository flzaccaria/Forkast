import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// Una riga ingrediente in fase di editing del piatto.
/// `qtyBase4` è null per gli ingredienti "quanto basta".
class DishIngredientDraft {
  DishIngredientDraft({
    required this.ingredientId,
    required this.qtyBase4,
  });

  final String ingredientId;
  final double? qtyBase4;
}

/// Accesso al catalogo piatti e alle relative righe ingrediente.
/// Filtrato per household (ADR-005), UUID client-side (ADR-003).
class DishRepository {
  DishRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Catalogo piatti ordinato per nome, filtrabile per testo e per tag (FR-15).
  /// `tagId`, se presente, limita ai piatti che hanno quel tag assegnato.
  Stream<List<Dish>> watchAll({String query = '', String? tagId}) {
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
    return q.watch();
  }

  /// Righe ingrediente di un piatto.
  Stream<List<DishIngredient>> watchIngredients(String dishId) {
    return (_db.select(_db.dishIngredients)
          ..where((di) => di.dishId.equals(dishId)))
        .watch();
  }

  /// Crea un piatto con le sue righe ingrediente e i tag in un'unica
  /// transazione. `tagIds` raccoglie portata (al più una) e attributi (FR-14).
  Future<String> create({
    required String name,
    required List<DishIngredientDraft> ingredients,
    List<String> tagIds = const [],
  }) async {
    final now = DateTime.now().toUtc();
    final dishId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.dishes).insert(
            DishesCompanion.insert(
              id: dishId,
              householdId: _householdId,
              name: name,
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
}
