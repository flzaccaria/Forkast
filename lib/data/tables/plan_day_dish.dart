import 'package:drift/drift.dart';

@DataClassName('PlanDayDish')
class PlanDayDishes extends Table {
  TextColumn get id => text()();
  TextColumn get planDayId => text()();
  TextColumn get dishId => text()();
  TextColumn get householdId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'plan_day_dish';
}
