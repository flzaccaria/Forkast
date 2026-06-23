import 'package:drift/drift.dart';

@DataClassName('Dish')
class Dishes extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  TextColumn get difficulty => text().nullable()();
  TextColumn get timeEstimate => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'dish';
}
