import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// Seed-translatable dish name carried by plan DTOs.
class DishSeedInfo {
  const DishSeedInfo({
    required this.name,
    this.seedKey,
    this.nameModified = false,
  });

  final String name;
  final String? seedKey;
  final bool nameModified;
}

/// Summary of an evening for the weekly view.
class DayOverview {
  DayOverview({
    required this.planDayId,
    required this.guests,
    this.dishes = const [],
  });

  final String planDayId;
  final int guests;
  final List<DishSeedInfo> dishes;

  int get dishCount => dishes.length;
}

/// A dish assigned to an evening, with the name resolved from the catalog.
class PlanDishEntry {
  PlanDishEntry({
    required this.planDayDishId,
    required this.dishId,
    required this.dishName,
    this.seedKey,
    this.nameModified = false,
  });

  final String planDayDishId;
  final String dishId;
  final String dishName;
  final String? seedKey;
  final bool nameModified;
}

/// Weekly planning (FR-7/8/9). All filtered by household (ADR-005),
/// client-side UUIDs (ADR-003), local-first writes.
///
/// `week_plan` and `plan_day` are created lazily: an empty week or evening
/// does not generate rows until the user assigns guests or dishes.
class PlanRepository {
  PlanRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  Future<Household> _getHousehold() =>
      (_db.select(_db.households)..where((h) => h.id.equals(_householdId)))
          .getSingle();

  /// Default guests for the household (FR-8).
  Future<int> defaultGuests() async => (await _getHousehold()).defaultGuests;

  /// Configured week start day (FR-20), `DateTime.weekday` convention
  /// (1 = Monday … 7 = Sunday).
  Future<int> weekStartDay() async => (await _getHousehold()).weekStartDay;

  Stream<WeekPlan?> watchWeekPlan(int year, int week) {
    return (_db.select(_db.weekPlans)
          ..where((w) =>
              w.householdId.equals(_householdId) &
              w.year.equals(year) &
              w.week.equals(week)))
        .watchSingleOrNull();
  }

  /// Per-day summary (guests + dishes) of the week, indexed by `dayOfWeek`.
  /// Reactive to changes on evenings and dishes. Carries seed data for
  /// render-time name translation.
  Stream<Map<int, DayOverview>> watchWeekOverview(String weekPlanId) {
    return _db
        .customSelect(
          'SELECT pd.id AS id, pd.day_of_week AS day_of_week, '
          'pd.guests AS guests, '
          'd.name AS dish_name, d.seed_key AS dish_seed_key, '
          'd.name_modified AS dish_name_modified '
          'FROM plan_day pd '
          'LEFT JOIN plan_day_dish pdd ON pdd.plan_day_id = pd.id '
          'LEFT JOIN dish d ON d.id = pdd.dish_id '
          'WHERE pd.week_plan_id = ? '
          'ORDER BY pd.day_of_week, pdd.sort_order',
          variables: [Variable.withString(weekPlanId)],
          readsFrom: {_db.planDays, _db.planDayDishes, _db.dishes},
        )
        .watch()
        .map((rows) {
      final map = <int, _OverviewAccum>{};
      for (final row in rows) {
        final dow = row.read<int>('day_of_week');
        final accum = map.putIfAbsent(
          dow,
          () => _OverviewAccum(
            planDayId: row.read<String>('id'),
            guests: row.read<int>('guests'),
          ),
        );
        final dishName = row.readNullable<String>('dish_name');
        if (dishName != null) {
          accum.dishes.add(DishSeedInfo(
            name: dishName,
            seedKey: row.readNullable<String>('dish_seed_key'),
            nameModified:
                (row.readNullable<int>('dish_name_modified') ?? 0) == 1,
          ));
        }
      }
      return {
        for (final e in map.entries)
          e.key: DayOverview(
            planDayId: e.value.planDayId,
            guests: e.value.guests,
            dishes: e.value.dishes,
          ),
      };
    });
  }

  /// Dishes of an evening, ordered, with the dish name.
  Stream<List<PlanDishEntry>> watchDayDishes(String planDayId) {
    final pdd = _db.planDayDishes;
    final dish = _db.dishes;
    final query = _db.select(pdd).join([
      innerJoin(dish, dish.id.equalsExp(pdd.dishId)),
    ])
      ..where(pdd.planDayId.equals(planDayId))
      ..orderBy([OrderingTerm(expression: pdd.sortOrder)]);
    return query.watch().map((rows) {
      return rows.map((row) {
        final p = row.readTable(pdd);
        final d = row.readTable(dish);
        return PlanDishEntry(
          planDayDishId: p.id,
          dishId: d.id,
          dishName: d.name,
          seedKey: d.seedKey,
          nameModified: d.nameModified ?? false,
        );
      }).toList();
    });
  }

  Future<String> _ensureWeekPlan(int year, int week) async {
    final existing = await (_db.select(_db.weekPlans)
          ..where((w) =>
              w.householdId.equals(_householdId) &
              w.year.equals(year) &
              w.week.equals(week)))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.weekPlans).insert(
          WeekPlansCompanion.insert(
            id: id,
            householdId: _householdId,
            year: year,
            week: week,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  /// Ensures the evening exists (year/week/dayOfWeek), creating week_plan and
  /// plan_day on the fly. A new evening's guests start from the household
  /// default (FR-8), then can be overridden.
  Future<PlanDay> ensurePlanDay(int year, int week, int dayOfWeek) async {
    final weekPlanId = await _ensureWeekPlan(year, week);
    final existing = await (_db.select(_db.planDays)
          ..where((d) =>
              d.weekPlanId.equals(weekPlanId) & d.dayOfWeek.equals(dayOfWeek)))
        .getSingleOrNull();
    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    final guests = await defaultGuests();
    final day = PlanDay(
      id: _uuid.v4(),
      weekPlanId: weekPlanId,
      householdId: _householdId,
      dayOfWeek: dayOfWeek,
      guests: guests,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.planDays).insert(
          PlanDaysCompanion.insert(
            id: day.id,
            weekPlanId: day.weekPlanId,
            householdId: day.householdId,
            dayOfWeek: day.dayOfWeek,
            guests: day.guests,
            createdAt: day.createdAt,
            updatedAt: day.updatedAt,
          ),
        );
    return day;
  }

  /// Sets the evening's guests (FR-8). Applies to all dishes.
  Future<void> setGuests(String planDayId, int guests) {
    return (_db.update(_db.planDays)..where((d) => d.id.equals(planDayId)))
        .write(PlanDaysCompanion(
      guests: Value(guests),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }

  /// Assigns the selected dishes to the evening, avoiding already-present
  /// duplicates. The same dish can appear on different days (FR-9).
  Future<void> addDishes(String planDayId, List<String> dishIds) async {
    if (dishIds.isEmpty) return;
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.planDayDishes)
          ..where((p) => p.planDayId.equals(planDayId)))
        .get();
    final already = existing.map((e) => e.dishId).toSet();
    var nextSort = existing.length;

    await _db.batch((b) {
      for (final dishId in dishIds) {
        if (already.contains(dishId)) continue;
        b.insert(
          _db.planDayDishes,
          PlanDayDishesCompanion.insert(
            id: _uuid.v4(),
            planDayId: planDayId,
            dishId: dishId,
            householdId: _householdId,
            sortOrder: Value(nextSort++),
            createdAt: now,
          ),
        );
      }
    });
  }

  Future<void> removeDish(String planDayDishId) {
    return (_db.delete(_db.planDayDishes)
          ..where((p) => p.id.equals(planDayDishId)))
        .go();
  }

  /// True if the week has at least one planned evening (with dishes).
  Future<bool> hasPlannedDishes(int year, int week) async {
    final plan = await (_db.select(_db.weekPlans)
          ..where((w) =>
              w.householdId.equals(_householdId) &
              w.year.equals(year) &
              w.week.equals(week)))
        .getSingleOrNull();
    if (plan == null) return false;
    final count = _db.planDayDishes.id.count();
    final query = _db.selectOnly(_db.planDays).join([
      innerJoin(_db.planDayDishes,
          _db.planDayDishes.planDayId.equalsExp(_db.planDays.id)),
    ])
      ..addColumns([count])
      ..where(_db.planDays.weekPlanId.equals(plan.id));
    final row = await query.getSingle();
    return (row.read(count) ?? 0) > 0;
  }

  /// Copies dishes and guests from week `from` into week `to` (FR-19). The
  /// list is NOT copied: it is regenerated from the plan (ADR-004).
  ///
  /// When the destination week is not empty the behavior is chosen by the
  /// caller (open point §8 of the requirements): with [replace] = true the
  /// destination evenings are cleared first; otherwise the dishes are added
  /// to the existing ones without duplicates.
  Future<void> copyWeek({
    required int fromYear,
    required int fromWeek,
    required int toYear,
    required int toWeek,
    required bool replace,
  }) async {
    final sourcePlan = await (_db.select(_db.weekPlans)
          ..where((w) =>
              w.householdId.equals(_householdId) &
              w.year.equals(fromYear) &
              w.week.equals(fromWeek)))
        .getSingleOrNull();
    if (sourcePlan == null) return;
    final sourceDays = await (_db.select(_db.planDays)
          ..where((d) => d.weekPlanId.equals(sourcePlan.id)))
        .get();
    if (sourceDays.isEmpty) return;

    for (final day in sourceDays) {
      final dishes = await (_db.select(_db.planDayDishes)
            ..where((p) => p.planDayId.equals(day.id))
            ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
          .get();
      if (dishes.isEmpty) continue;

      final target = await ensurePlanDay(toYear, toWeek, day.dayOfWeek);
      await setGuests(target.id, day.guests);
      if (replace) {
        await (_db.delete(_db.planDayDishes)
              ..where((p) => p.planDayId.equals(target.id)))
            .go();
      }
      await addDishes(target.id, dishes.map((d) => d.dishId).toList());
    }
  }
}

class _OverviewAccum {
  _OverviewAccum({required this.planDayId, required this.guests});

  final String planDayId;
  final int guests;
  final List<DishSeedInfo> dishes = [];
}
