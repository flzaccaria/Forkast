import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/database.dart';
import 'package:forkast/data/repositories/plan_repository.dart';

/// Verifica il flusso di pianificazione su uno schema "stile PowerSync"
/// (tabelle senza DEFAULT), così da intercettare anche eventuali default
/// drift non applicati (es. plan_day_dish.sort_order).
void main() {
  late AppDatabase db;
  const householdId = 'hh-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('''
      CREATE TABLE household (
        id TEXT PRIMARY KEY, name TEXT, default_guests INTEGER,
        week_start_day INTEGER, auto_regen INTEGER,
        created_at TEXT, updated_at TEXT)''');
    await db.customStatement('''
      CREATE TABLE dish (
        id TEXT PRIMARY KEY, household_id TEXT, name TEXT,
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

    // Un household con default commensali 4.
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

  test('ensurePlanDay crea la serata coi commensali di default ed è idempotente',
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

  test('setGuests aggiorna i commensali della serata', () async {
    final repo = PlanRepository(db, householdId);
    final day = await repo.ensurePlanDay(2026, 25, DateTime.tuesday);
    await repo.setGuests(day.id, 6);

    final overview = await repo
        .watchWeekOverview((await repo.watchWeekPlan(2026, 25).first)!.id)
        .first;
    expect(overview[DateTime.tuesday]!.guests, 6);
  });

  test('addDishes assegna i piatti senza duplicati e li conta', () async {
    final repo = PlanRepository(db, householdId);
    final pasta = await seedDish('Pasta');
    final sugo = await seedDish('Sugo');

    final day = await repo.ensurePlanDay(2026, 25, DateTime.friday);
    await repo.addDishes(day.id, [pasta, sugo]);
    // Ri-aggiunge pasta: deve essere ignorato (no duplicati).
    await repo.addDishes(day.id, [pasta]);

    final entries = await repo.watchDayDishes(day.id).first;
    expect(entries.map((e) => e.dishName), ['Pasta', 'Sugo']);

    final weekPlan = (await repo.watchWeekPlan(2026, 25).first)!;
    final overview = await repo.watchWeekOverview(weekPlan.id).first;
    expect(overview[DateTime.friday]!.dishCount, 2);
  });

  test('removeDish toglie il piatto dalla serata', () async {
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

  test('lo stesso piatto può stare in giorni diversi (FR-9)', () async {
    final repo = PlanRepository(db, householdId);
    final pasta = await seedDish('Pasta');
    final mon = await repo.ensurePlanDay(2026, 25, DateTime.monday);
    final tue = await repo.ensurePlanDay(2026, 25, DateTime.tuesday);
    await repo.addDishes(mon.id, [pasta]);
    await repo.addDishes(tue.id, [pasta]);

    expect(await repo.watchDayDishes(mon.id).first, hasLength(1));
    expect(await repo.watchDayDishes(tue.id).first, hasLength(1));
  });
}
