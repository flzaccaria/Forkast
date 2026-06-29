import 'package:drift/drift.dart';

class ListRecurringExclusions extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get ingredientId => text()();
  TextColumn get householdId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {shoppingListId, ingredientId}
      ];

  @override
  String get tableName => 'list_recurring_exclusion';
}
