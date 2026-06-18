import 'package:drift/drift.dart';

class ListGeneratedRows extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get ingredientId => text()();
  TextColumn get householdId => text()();
  RealColumn get qty => real().nullable()();
  TextColumn get unit => text()();
  BoolColumn get isQb => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'list_generated_row';
}
