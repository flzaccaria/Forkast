import 'package:drift/drift.dart';

class WeekPlans extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  IntColumn get year => integer()();
  IntColumn get week => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{householdId, year, week}];

  @override
  String get tableName => 'week_plan';
}
