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

  Future<void> create({
    required String name,
    required String unit,
    bool isQb = false,
  }) {
    final now = DateTime.now().toUtc();
    return _db.into(_db.ingredients).insert(
          IngredientsCompanion.insert(
            id: _uuid.v4(),
            householdId: _householdId,
            name: name,
            unit: unit,
            isQb: Value(isQb),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }
}
