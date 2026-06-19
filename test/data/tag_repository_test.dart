import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/tag_repository.dart';

/// Tag system (FR-14/15) on a "PowerSync-style" schema (without DEFAULT), to
/// catch unapplied drift defaults (tag.sort_order).
void main() {
  late AppDatabase db;
  late TagRepository repo;
  const householdId = 'hh-1';

  Future<void> exec(String sql) => db.customStatement(sql);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await exec('''CREATE TABLE tag (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT, "group" TEXT,
      color TEXT, sort_order INTEGER, created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish (
      id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
      created_at TEXT, updated_at TEXT)''');
    await exec('''CREATE TABLE dish_tag (
      id TEXT PRIMARY KEY, dish_id TEXT, tag_id TEXT, household_id TEXT,
      created_at TEXT)''');
    repo = TagRepository(db, householdId);
  });

  tearDown(() async => db.close());

  Future<void> seedDish(String id) async {
    final now = DateTime.now().toUtc();
    await db.into(db.dishes).insert(DishesCompanion.insert(
          id: id,
          householdId: householdId,
          name: id,
          createdAt: now,
          updatedAt: now,
        ));
  }

  test('creates tags by group and lists them separately', () async {
    await repo.create(name: 'Primo', group: TagGroup.portata);
    await repo.create(name: 'Secondo', group: TagGroup.portata);
    await repo.create(name: 'Veloce', group: TagGroup.attributo);

    final portate = await repo.watchByGroup(TagGroup.portata).first;
    final attributi = await repo.watchByGroup(TagGroup.attributo).first;
    expect(portate.map((t) => t.name), ['Primo', 'Secondo']);
    expect(attributi.map((t) => t.name), ['Veloce']);
  });

  test('course is single-choice: replaces the previous one', () async {
    await seedDish('d1');
    final primo = await repo.create(name: 'Primo', group: TagGroup.portata);
    final secondo = await repo.create(name: 'Secondo', group: TagGroup.portata);

    await repo.setDishPortata('d1', primo.id);
    expect((await repo.watchDishTags('d1').first).single.id, primo.id);

    await repo.setDishPortata('d1', secondo.id);
    expect((await repo.watchDishTags('d1').first).single.id, secondo.id);

    await repo.setDishPortata('d1', null);
    expect(await repo.watchDishTags('d1').first, isEmpty);
  });

  test('multiple attributes: sets and replaces the set', () async {
    await seedDish('d1');
    final a = await repo.create(name: 'Veloce', group: TagGroup.attributo);
    final b = await repo.create(name: 'Pesce', group: TagGroup.attributo);
    final c = await repo.create(name: 'Vegano', group: TagGroup.attributo);

    await repo.setDishAttributes('d1', {a.id, b.id});
    var ids = (await repo.watchDishTags('d1').first).map((t) => t.id).toSet();
    expect(ids, {a.id, b.id});

    await repo.setDishAttributes('d1', {c.id});
    ids = (await repo.watchDishTags('d1').first).map((t) => t.id).toSet();
    expect(ids, {c.id});
  });

  test('course and attributes coexist and are managed independently',
      () async {
    await seedDish('d1');
    final primo = await repo.create(name: 'Primo', group: TagGroup.portata);
    final veloce = await repo.create(name: 'Veloce', group: TagGroup.attributo);

    await repo.setDishPortata('d1', primo.id);
    await repo.setDishAttributes('d1', {veloce.id});
    expect((await repo.watchDishTags('d1').first).length, 2);

    // Changing the attributes does not touch the course.
    await repo.setDishAttributes('d1', {});
    final remaining = await repo.watchDishTags('d1').first;
    expect(remaining.single.id, primo.id);
  });

  test('protected deletion when the tag is in use', () async {
    await seedDish('d1');
    final t = await repo.create(name: 'Primo', group: TagGroup.portata);
    await repo.setDishPortata('d1', t.id);

    expect(await repo.usageCount(t.id), 1);
    expect(await repo.deleteIfUnused(t.id), false);

    await repo.setDishPortata('d1', null);
    expect(await repo.deleteIfUnused(t.id), true);
    expect(await repo.watchByGroup(TagGroup.portata).first, isEmpty);
  });
}
