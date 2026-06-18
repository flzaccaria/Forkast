import 'package:drift/drift.dart';

class DishTags extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text()();
  TextColumn get tagId => text()();
  TextColumn get householdId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{dishId, tagId}];
}
