import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/plan_repository.dart';

/// Verifies the planning flow on a "PowerSync-style" schema
/// (tables without DEFAULT), so as to also catch any unapplied drift
/// defaults (e.g. plan_day_dish.sort_order).
void main() {
  late AppDatabase db;
  const householdId = 'hh-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('''
      CREATE TABLE household (
        id TEXT PRIMARY KEY, name TEXT, default_guests INTEGER,
        week_start_day INTEGER, auto_regen INTEGER, seeded_at TEXT,
        created_at TEXT, updated_at TEXT)''');
    await db.customStatement('''
      CREATE TABLE dish (
        id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
        difficulty TEXT, time_estimate TEXT,
        created_at TEXT, updated_at TEXT)''');
    await db.customStatement('''
      CREATE TABLE week_plan (
        id TEXT PRIMARY KEY, household_id TEXT, year INTEGER, week INTEGER,
        created_at TEXT, updated_at TEXT)''');
    await db.customStatement('''
      CREATE TABLE plan_day (
        id TEXT PRIMARY KEY, week_plan_id TEXT, household_id TEXT,
        day_of_week INTEGER, guests INTEGER,
        created_at TEXT, updated_at TEXT)''');
    await db.customStatement('''
      CREATE TABLE plan_day_dish (
        id TEXT PRIMARY KEY, plan_day_id TEXT, dish_id TEXT, household_id TEXT,
        sort_order INTEGER, created_at TEXT)''');

    // A household with default guests 4.
    final now = DateTime.now().toUtc();
    await db.into(db.households).insert(HouseholdsCompanion.insert(
          id: householdId,
          defaultGuests: const Value(4),
          weekStartDay: const Value(1),
          autoRegen: const Value(false),
          createdAt: now,
          updatedAt: now,
        ));
  });

  tearDown(() async => db.close());

  Future<String> seedDish(String name) async {
    final now = DateTime.now().toUtc();
    final id = 'dish-$name';
    await db.into(db.dishes).insert(DishesCompanion.insert(
          id: id,
          householdId: householdId,
          name: name,
          createdAt: now,
          updatedAt: now,
        ));
    return id;
  }

  test('ensurePlanDay creates the evening with default guests and is idempotent',
      () async {
    final repo = PlanRepository(db, householdId);
    final day1 = await repo.ensurePlanDay(2026, 25, DateTime.monday);
    expect(day1.guests, 4);
    expect(day1.dayOfWeek, DateTime.monday);

    final day2 = await repo.ensurePlanDay(2026, 25, DateTime.monday);
    expect(day2.id, day1.id);

    final count =
        await db.customSelect('SELECT COUNT(*) AS c FROM plan_day').getSingle();
    expect(count.read<int>('c'), 1);
  });

  test('setGuests updates the guests of the evening', () async {
    final repo = PlanRepository(db, householdId);
    final day = await repo.ensurePlanDay(2026, 25, DateTime.tuesday);
    await repo.setGuests(day.id, 6);

    final overview = await repo
        .watchWeekOverview((await repo.watchWeekPlan(2026, 25).first)!.id)
        .first;
    expect(overview[DateTime.tuesday]!.guests, 6);
  });

  test('addDishes assigns the dishes without duplicates and counts them', () async {
    final repo = PlanRepository(db, householdId);
    final pasta = await seedDish('Pasta');
    final sugo = await seedDish('Sugo');

    final day = await repo.ensurePlanDay(2026, 25, DateTime.friday);
    await repo.addDishes(day.id, [pasta, sugo]);
    // Re-adds pasta: it must be ignored (no duplicates).
    await repo.addDishes(day.id, [pasta]);

    final entries = await repo.watchDayDishes(day.id).first;
    expect(entries.map((e) => e.dishName), ['Pasta', 'Sugo']);

    final weekPlan = (await repo.watchWeekPlan(2026, 25).first)!;
    final overview = await repo.watchWeekOverview(weekPlan.id).first;
    expect(overview[DateTime.friday]!.dishCount, 2);
  });

  test('removeDish removes the dish from the evening', () async {
    final repo = PlanRepository(db, householdId);
    final pasta = await seedDish('Pasta');
    final day = await repo.ensurePlanDay(2026, 25, DateTime.saturday);
    await repo.addDishes(day.id, [pasta]);

    var entries = await repo.watchDayDishes(day.id).first;
    expect(entries, hasLength(1));

    await repo.removeDish(entries.single.planDayDishId);
    entries = await repo.watchDayDishes(day.id).first;
    expect(entries, isEmpty);
  });

  test('the same dish can be in different days (FR-9)', () async {
    final repo = PlanRepository(db, householdId);
    final pasta = await seedDish('Pasta');
    final mon = await repo.ensurePlanDay(2026, 25, DateTime.monday);
    final tue = await repo.ensurePlanDay(2026, 25, DateTime.tuesday);
    await repo.addDishes(mon.id, [pasta]);
    await repo.addDishes(tue.id, [pasta]);

    expect(await repo.watchDayDishes(mon.id).first, hasLength(1));
    expect(await repo.watchDayDishes(tue.id).first, hasLength(1));
  });

  group('FR-19 copy previous week', () {
    test('hasPlannedDishes reflects the planned dishes', () async {
      final repo = PlanRepository(db, householdId);
      expect(await repo.hasPlannedDishes(2026, 25), false);
      final pasta = await seedDish('Pasta');
      final day = await repo.ensurePlanDay(2026, 25, DateTime.monday);
      expect(await repo.hasPlannedDishes(2026, 25), false); // empty evening
      await repo.addDishes(day.id, [pasta]);
      expect(await repo.hasPlannedDishes(2026, 25), true);
    });

    test('copies dishes and guests into the destination week', () async {
      final repo = PlanRepository(db, householdId);
      final pasta = await seedDish('Pasta');
      final mon = await repo.ensurePlanDay(2026, 25, DateTime.monday);
      await repo.setGuests(mon.id, 6);
      await repo.addDishes(mon.id, [pasta]);

      await repo.copyWeek(
          fromYear: 2026, fromWeek: 25, toYear: 2026, toWeek: 26, replace: false);

      final target = await repo.ensurePlanDay(2026, 26, DateTime.monday);
      expect(target.guests, 6);
      final entries = await repo.watchDayDishes(target.id).first;
      expect(entries.map((e) => e.dishName), ['Pasta']);
    });

    test('replace clears the existing dishes of the destination', () async {
      final repo = PlanRepository(db, householdId);
      final pasta = await seedDish('Pasta');
      final riso = await seedDish('Riso');
      final src = await repo.ensurePlanDay(2026, 25, DateTime.monday);
      await repo.addDishes(src.id, [pasta]);
      final dst = await repo.ensurePlanDay(2026, 26, DateTime.monday);
      await repo.addDishes(dst.id, [riso]);

      await repo.copyWeek(
          fromYear: 2026, fromWeek: 25, toYear: 2026, toWeek: 26, replace: true);
      final entries = await repo.watchDayDishes(dst.id).first;
      expect(entries.map((e) => e.dishName), ['Pasta']);
    });

    test('merge adds without duplicates', () async {
      final repo = PlanRepository(db, householdId);
      final pasta = await seedDish('Pasta');
      final riso = await seedDish('Riso');
      final src = await repo.ensurePlanDay(2026, 25, DateTime.monday);
      await repo.addDishes(src.id, [pasta, riso]);
      final dst = await repo.ensurePlanDay(2026, 26, DateTime.monday);
      await repo.addDishes(dst.id, [riso]);

      await repo.copyWeek(
          fromYear: 2026, fromWeek: 25, toYear: 2026, toWeek: 26, replace: false);
      final entries = await repo.watchDayDishes(dst.id).first;
      expect(entries.map((e) => e.dishName).toSet(), {'Pasta', 'Riso'});
      expect(entries, hasLength(2));
    });
  });
}
