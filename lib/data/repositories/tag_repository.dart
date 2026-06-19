import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// Gruppi di tag (FR-14). La `portata` è a scelta singola e facoltativa; gli
/// `attributo` sono multipli.
class TagGroup {
  static const portata = 'portata';
  static const attributo = 'attributo';
}

/// Vocabolario curato dei tag dei piatti (FR-14), gestito nelle impostazioni.
/// Filtrato per household (ADR-005), UUID client-side (ADR-003).
class TagRepository {
  TagRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Tutti i tag, ordinati per gruppo poi per `sortOrder`/nome.
  Stream<List<Tag>> watchAll() {
    return (_db.select(_db.tags)
          ..where((t) => t.householdId.equals(_householdId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Tag di un gruppo (`portata` o `attributo`).
  Stream<List<Tag>> watchByGroup(String group) {
    return (_db.select(_db.tags)
          ..where((t) =>
              t.householdId.equals(_householdId) & t.tagGroup.equals(group))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Tag assegnati a un piatto.
  Stream<List<Tag>> watchDishTags(String dishId) {
    final dt = _db.dishTags;
    final tag = _db.tags;
    final query = _db.select(dt).join([
      innerJoin(tag, tag.id.equalsExp(dt.tagId)),
    ])
      ..where(dt.dishId.equals(dishId));
    return query.watch().map((rows) => rows.map((r) => r.readTable(tag)).toList());
  }

  Future<Tag> create({
    required String name,
    required String group,
    String? color,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.tags).insert(TagsCompanion.insert(
          id: id,
          householdId: _householdId,
          name: name,
          tagGroup: group,
          color: Value(color),
          createdAt: now,
          updatedAt: now,
        ));
    return Tag(
      id: id,
      householdId: _householdId,
      name: name,
      tagGroup: group,
      color: color,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> rename(String tagId, String name) {
    return (_db.update(_db.tags)..where((t) => t.id.equals(tagId))).write(
        TagsCompanion(name: Value(name), updatedAt: Value(DateTime.now().toUtc())));
  }

  /// Numero di piatti che usano il tag: serve a proteggerne l'eliminazione
  /// (coerente con FR-17) e a mostrarne l'impatto.
  Future<int> usageCount(String tagId) async {
    final count = _db.dishTags.id.count();
    final query = _db.selectOnly(_db.dishTags)
      ..addColumns([count])
      ..where(_db.dishTags.tagId.equals(tagId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Elimina un tag inutilizzato. Restituisce false se è ancora assegnato a
  /// qualche piatto (eliminazione protetta).
  Future<bool> deleteIfUnused(String tagId) async {
    if (await usageCount(tagId) > 0) return false;
    await (_db.delete(_db.tags)..where((t) => t.id.equals(tagId))).go();
    return true;
  }

  /// Imposta la portata (scelta singola, facoltativa) di un piatto: rimuove
  /// l'eventuale portata precedente e assegna quella nuova (o nessuna).
  Future<void> setDishPortata(String dishId, String? tagId) async {
    final portatas = await (_db.select(_db.tags)
          ..where((t) =>
              t.householdId.equals(_householdId) &
              t.tagGroup.equals(TagGroup.portata)))
        .get();
    final portataIds = portatas.map((t) => t.id).toList();
    await (_db.delete(_db.dishTags)
          ..where((dt) =>
              dt.dishId.equals(dishId) & dt.tagId.isIn(portataIds)))
        .go();
    if (tagId != null) await _assign(dishId, tagId);
  }

  /// Sostituisce l'insieme degli attributi di un piatto.
  Future<void> setDishAttributes(String dishId, Set<String> tagIds) async {
    final attributes = await (_db.select(_db.tags)
          ..where((t) =>
              t.householdId.equals(_householdId) &
              t.tagGroup.equals(TagGroup.attributo)))
        .get();
    final attributeIds = attributes.map((t) => t.id).toList();
    await (_db.delete(_db.dishTags)
          ..where((dt) =>
              dt.dishId.equals(dishId) & dt.tagId.isIn(attributeIds)))
        .go();
    for (final id in tagIds) {
      await _assign(dishId, id);
    }
  }

  Future<void> _assign(String dishId, String tagId) {
    return _db.into(_db.dishTags).insert(
          DishTagsCompanion.insert(
            id: _uuid.v4(),
            dishId: dishId,
            tagId: tagId,
            householdId: _householdId,
            createdAt: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}
