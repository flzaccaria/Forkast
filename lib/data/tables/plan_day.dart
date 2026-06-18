import 'package:drift/drift.dart';

class PlanDays extends Table {
  TextColumn get id => text()();
  TextColumn get weekPlanId => text()();
  TextColumn get householdId => text()();
  IntColumn get dayOfWeek => integer()();
  IntColumn get guests => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{weekPlanId, dayOfWeek}];
}
