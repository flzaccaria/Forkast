import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

/// Riepilogo di una serata per la vista settimanale.
class DayOverview {
  DayOverview({
    required this.planDayId,
    required this.guests,
    required this.dishCount,
  });

  final String planDayId;
  final int guests;
  final int dishCount;
}

/// Un piatto assegnato a una serata, con il nome risolto dal catalogo.
class PlanDishEntry {
  PlanDishEntry({
    required this.planDayDishId,
    required this.dishId,
    required this.dishName,
  });

  final String planDayDishId;
  final String dishId;
  final String dishName;
}

/// Pianificazione settimanale (FR-7/8/9). Tutto filtrato per household
/// (ADR-005), UUID client-side (ADR-003), scritture local-first.
///
/// I `week_plan` e i `plan_day` sono creati pigramente: una settimana o una
/// serata vuota non genera righe finché l'utente non assegna commensali o
/// piatti.
class PlanRepository {
  PlanRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  static const _uuid = Uuid();

  /// Valore predefinito di commensali per l'household (FR-8).
  Future<int> defaultGuests() async {
    final household = await (_db.select(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .getSingle();
    return household.defaultGuests;
  }

  /// Giorno di inizio settimana configurato (FR-20), convenzione
  /// `DateTime.weekday` (1 = lunedì … 7 = domenica).
  Future<int> weekStartDay() async {
    final household = await (_db.select(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .getSingle();
    return household.weekStartDay;
  }

  Stream<WeekPlan?> watchWeekPlan(int year, int week) {
    return (_db.select(_db.weekPlans)
          ..where((w) =>
              w.householdId.equals(_householdId) &
              w.year.equals(year) &
              w.week.equals(week)))
        .watchSingleOrNull();
  }

  /// Riepilogo per giorno (commensali + numero piatti) della settimana,
  /// indicizzato per `dayOfWeek`. Reattivo a modifiche su serate e piatti.
  Stream<Map<int, DayOverview>> watchWeekOverview(String weekPlanId) {
    return _db
        .customSelect(
          'SELECT pd.id AS id, pd.day_of_week AS day_of_week, '
          'pd.guests AS guests, COUNT(pdd.id) AS dish_count '
          'FROM plan_day pd '
          'LEFT JOIN plan_day_dish pdd ON pdd.plan_day_id = pd.id '
          'WHERE pd.week_plan_id = ? '
          'GROUP BY pd.id',
          variables: [Variable.withString(weekPlanId)],
          readsFrom: {_db.planDays, _db.planDayDishes},
        )
        .watch()
        .map((rows) {
      final map = <int, DayOverview>{};
      for (final row in rows) {
        final dow = row.read<int>('day_of_week');
        map[dow] = DayOverview(
          planDayId: row.read<String>('id'),
          guests: row.read<int>('guests'),
          dishCount: row.read<int>('dish_count'),
        );
      }
      return map;
    });
  }

  /// Piatti di una serata, ordinati, con il nome del piatto.
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

  /// Garantisce l'esistenza della serata (year/week/dayOfWeek), creando al
  /// volo week_plan e plan_day. I commensali di una serata nuova partono dal
  /// default dell'household (FR-8), poi sono sovrascrivibili.
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

  /// Imposta i commensali della serata (FR-8). Vale per tutti i piatti.
  Future<void> setGuests(String planDayId, int guests) {
    return (_db.update(_db.planDays)..where((d) => d.id.equals(planDayId)))
        .write(PlanDaysCompanion(
      guests: Value(guests),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }

  /// Assegna i piatti selezionati alla serata, evitando i duplicati già
  /// presenti. Lo stesso piatto può stare in giorni diversi (FR-9).
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
}
