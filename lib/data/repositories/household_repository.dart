import 'package:drift/drift.dart';

import '../database.dart';

/// Global household settings (FR-8/20/21): default guests, week start day,
/// and automatic list regeneration.
/// Always filtered by household (ADR-005), local-first writes.
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

  /// Default guests for new evenings (FR-8). Minimum 1.
  Future<void> setDefaultGuests(int guests) {
    return _write(HouseholdsCompanion(defaultGuests: Value(guests.clamp(1, 99))));
  }

  /// Week start day (FR-20), `DateTime.weekday` convention
  /// (1 = Monday … 7 = Sunday).
  Future<void> setWeekStartDay(int weekday) {
    return _write(HouseholdsCompanion(weekStartDay: Value(weekday)));
  }

  /// Automatic list regeneration when the plan diverges (FR-21).
  Future<void> setAutoRegen(bool value) {
    return _write(HouseholdsCompanion(autoRegen: Value(value)));
  }

  Future<void> _write(HouseholdsCompanion patch) {
    return (_db.update(_db.households)
          ..where((h) => h.id.equals(_householdId)))
        .write(patch.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }
}
