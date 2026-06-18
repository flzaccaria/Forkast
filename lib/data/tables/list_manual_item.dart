import 'package:drift/drift.dart';

class ListManualItems extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  RealColumn get qty => real().nullable()();
  TextColumn get unit => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
