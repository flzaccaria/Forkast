import 'package:drift/drift.dart';

class ListChecks extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get ingredientId => text().nullable()();
  TextColumn get manualItemId => text().nullable()();
  TextColumn get householdId => text()();
  BoolColumn get checked => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'list_check';
}
