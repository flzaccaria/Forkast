import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/household_repository.dart';

/// Global settings (FR-8/20) on a "PowerSync-style" schema (without
/// DEFAULT), to catch unapplied drift defaults.
void main() {
  late AppDatabase db;
  late HouseholdRepository repo;
  const householdId = 'hh-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('''
      CREATE TABLE household (
        id TEXT PRIMARY KEY, name TEXT, default_guests INTEGER,
        week_start_day INTEGER, seeded_at TEXT,
        created_at TEXT, updated_at TEXT)''');
    final now = DateTime.now().toUtc();
    await db.into(db.households).insert(HouseholdsCompanion.insert(
          id: householdId,
          defaultGuests: const Value(4),
          weekStartDay: const Value(1),
          createdAt: now,
          updatedAt: now,
        ));
    repo = HouseholdRepository(db, householdId);
  });

  tearDown(() async => db.close());

  test('reads the initial values', () async {
    final h = await repo.get();
    expect(h.defaultGuests, 4);
    expect(h.weekStartDay, 1);
  });

  test('updates default guests, clamping the minimum to 1', () async {
    await repo.setDefaultGuests(6);
    expect((await repo.get()).defaultGuests, 6);

    await repo.setDefaultGuests(0);
    expect((await repo.get()).defaultGuests, 1);
  });

  test('updates week start day', () async {
    await repo.setWeekStartDay(7);
    final h = await repo.get();
    expect(h.weekStartDay, 7);
  });

  test('watch emits changes', () async {
    final future = repo.watch().firstWhere((h) => h.defaultGuests == 8);
    await repo.setDefaultGuests(8);
    expect((await future).defaultGuests, 8);
  });
}
