import 'package:drift/drift.dart';

class ListOverrides extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get ingredientId => text()();
  TextColumn get householdId => text()();
  RealColumn get qtyOverride => real().nullable()();
  BoolColumn get removed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{shoppingListId, ingredientId}];

  @override
  String get tableName => 'list_override';
}
