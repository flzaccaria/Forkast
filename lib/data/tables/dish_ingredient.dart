import 'package:drift/drift.dart';

class DishIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text()();
  TextColumn get ingredientId => text()();
  TextColumn get householdId => text()();
  RealColumn get qtyBase4 => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{dishId, ingredientId}];
}
