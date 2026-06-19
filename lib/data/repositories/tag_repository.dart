import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// Tag groups (FR-14). The `portata` is single-choice and optional; the
/// `attributo` ones are multiple.
class TagGroup {
  static const portata = 'portata';
  static const attributo = 'attributo';
}

/// Curated vocabulary of dish tags (FR-14), managed in the settings.
/// Filtered by household (ADR-005), client-side UUIDs (ADR-003).
class TagRepository {
  TagRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// All tags, ordered by group then by `sortOrder`/name.
  Stream<List<Tag>> watchAll() {
    return (_db.select(_db.tags)
          ..where((t) => t.householdId.equals(_householdId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Tags of a group (`portata` or `attributo`).
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

  /// Tags assigned to a dish.
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
          // drift default not applied by the PowerSync schema: set explicitly.
          sortOrder: const Value(0),
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

  /// Number of dishes that use the tag: used to protect its deletion
  /// (consistent with FR-17) and to show its impact.
  Future<int> usageCount(String tagId) async {
    final count = _db.dishTags.id.count();
    final query = _db.selectOnly(_db.dishTags)
      ..addColumns([count])
      ..where(_db.dishTags.tagId.equals(tagId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Deletes an unused tag. Returns false if it is still assigned to some
  /// dish (protected deletion).
  Future<bool> deleteIfUnused(String tagId) async {
    if (await usageCount(tagId) > 0) return false;
    await (_db.delete(_db.tags)..where((t) => t.id.equals(tagId))).go();
    return true;
  }

  /// Sets the portata (single choice, optional) of a dish: removes any
  /// previous portata and assigns the new one (or none).
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

  /// Replaces the set of attributes of a dish.
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
