import 'package:drift/drift.dart';

import '../database.dart';

/// Impostazioni globali dell'household (FR-8/20/21): commensali predefiniti,
/// giorno di inizio settimana e rigenerazione automatica della lista.
/// Sempre filtrato per household (ADR-005), scritture local-first.
class HouseholdRepository {
  HouseholdRepository(this._db, this._householdId);

  final AppDatabase _db;
  final String _householdId;

  Stream<Household> watch() {
    return (_db.select(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .watchSingle();
  }

  Future<Household> get() {
    return (_db.select(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .getSingle();
  }

  /// Commensali predefiniti per le nuove serate (FR-8). Minimo 1.
  Future<void> setDefaultGuests(int guests) {
    return _write(HouseholdsCompanion(defaultGuests: Value(guests.clamp(1, 99))));
  }

  /// Giorno di inizio settimana (FR-20), convenzione `DateTime.weekday`
  /// (1 = lunedì … 7 = domenica).
  Future<void> setWeekStartDay(int weekday) {
    return _write(HouseholdsCompanion(weekStartDay: Value(weekday)));
  }

  /// Rigenerazione automatica della lista quando il piano diverge (FR-21).
  Future<void> setAutoRegen(bool value) {
    return _write(HouseholdsCompanion(autoRegen: Value(value)));
  }

  Future<void> _write(HouseholdsCompanion patch) {
    return (_db.update(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .write(patch.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }
}
