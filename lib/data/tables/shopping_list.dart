import 'package:drift/drift.dart';

class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get weekPlanId => text()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get planHash => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'shopping_list';
}
