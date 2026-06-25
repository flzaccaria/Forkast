import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/seed_catalog.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

const _miniCsv = '''
nome,reparto,unita,qb
Carote,Ortofrutta,g,false
Sale fino,Dispensa,g,true
Uova,Latticini e uova,pz,false
''';

Future<String> _insertHousehold(AppDatabase db, {DateTime? seededAt}) async {
  final now = DateTime.now().toUtc();
  final id = _uuid.v4();
  await db.into(db.households).insert(HouseholdsCompanion.insert(
        id: id,
        defaultGuests: const Value(4),
        weekStartDay: const Value(1),
        autoRegen: const Value(false),
        seededAt: Value(seededAt),
        createdAt: now,
        updatedAt: now,
      ));
  return id;
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('''
      CREATE TABLE household (
        id TEXT PRIMARY KEY,
        name TEXT,
        default_guests INTEGER,
        week_start_day INTEGER,
        auto_regen INTEGER,
        seeded_at TEXT,
        created_at TEXT,
        updated_at TEXT
      )''');
    await db.customStatement('''
      CREATE TABLE ingredient (
        id TEXT PRIMARY KEY,
        household_id TEXT,
        name TEXT,
        unit TEXT,
        is_qb INTEGER DEFAULT 0,
        category TEXT,
        rounding_kind TEXT,
        seed_key TEXT,
        name_modified INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )''');
  });

  tearDown(() => db.close());

  test('seeds ingredients on empty household', () async {
    final hid = await _insertHousehold(db);

    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);

    final all = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    expect(all.length, 3);
    expect(all.map((i) => i.name).toList()..sort(),
        ['Carote', 'Sale fino', 'Uova']);

    final sale = all.firstWhere((i) => i.name == 'Sale fino');
    expect(sale.isQb, true);
    expect(sale.unit, 'q.b.');

    final carote = all.firstWhere((i) => i.name == 'Carote');
    expect(carote.isQb, false);
    expect(carote.unit, 'g');
    expect(carote.category, 'Ortofrutta');

    final h = await (db.select(db.households)
          ..where((h) => h.id.equals(hid)))
        .getSingle();
    expect(h.seededAt, isNotNull);
  });

  test('calling seed twice produces no duplicates', () async {
    final hid = await _insertHousehold(db);

    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);
    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);

    final all = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    expect(all.length, 3);
  });

  test('skips seed when seeded_at is already set', () async {
    final hid = await _insertHousehold(db, seededAt: DateTime.now().toUtc());

    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);

    final all = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    expect(all.length, 0);
  });

  test('skips seed when ingredients already exist', () async {
    final hid = await _insertHousehold(db);
    final now = DateTime.now().toUtc();
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: _uuid.v4(),
          householdId: hid,
          name: 'Existing',
          unit: 'g',
          createdAt: now,
          updatedAt: now,
        ));

    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);

    final all = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    expect(all.length, 1);
    expect(all.first.name, 'Existing');
  });

  test('seeded ingredients are normal editable rows', () async {
    final hid = await _insertHousehold(db);
    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);

    final carote = (await (db.select(db.ingredients)
              ..where((i) => i.name.equals('Carote')))
            .get())
        .first;
    await (db.delete(db.ingredients)..where((i) => i.id.equals(carote.id)))
        .go();

    final all = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    expect(all.length, 2);

    // Re-calling seed does NOT re-add deleted item (run-once guard)
    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);
    final afterRestart = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    expect(afterRestart.length, 2);
  });

  test('every seeded ingredient has non-null roundingKind', () async {
    final hid = await _insertHousehold(db);
    await seedCatalogIfNeeded(db, hid, csvOverride: _miniCsv);

    final all = await (db.select(db.ingredients)
          ..where((i) => i.householdId.equals(hid)))
        .get();
    for (final ing in all) {
      expect(ing.roundingKind, isNotNull,
          reason: '${ing.name} (isQb=${ing.isQb}) has null roundingKind');
    }
  });

  test('backfillRoundingKind fixes null roundingKind', () async {
    final hid = await _insertHousehold(db);
    final now = DateTime.now().toUtc();
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: 'qb-item',
          householdId: hid,
          name: 'Sale',
          unit: 'q.b.',
          isQb: const Value(true),
          roundingKind: const Value(null),
          createdAt: now,
          updatedAt: now,
        ));

    final before = await (db.select(db.ingredients)
          ..where((i) => i.id.equals('qb-item')))
        .getSingle();
    expect(before.roundingKind, isNull);

    await backfillRoundingKind(db, hid);

    final after = await (db.select(db.ingredients)
          ..where((i) => i.id.equals('qb-item')))
        .getSingle();
    expect(after.roundingKind, isNotNull);
    expect(after.roundingKind, 'weight');
  });

  test('parseSeedCsv parses correctly', () {
    final rows = parseSeedCsv(_miniCsv);
    expect(rows.length, 3);
    expect(rows[0].name, 'Carote');
    expect(rows[0].category, 'Ortofrutta');
    expect(rows[0].unit, 'g');
    expect(rows[0].isQb, false);
    expect(rows[1].isQb, true);
  });
}
