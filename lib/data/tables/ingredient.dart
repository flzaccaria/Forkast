import 'package:drift/drift.dart';

class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  BoolColumn get isQb => boolean().withDefault(const Constant(false))();
  // Supermarket department (fixed list in core/reparto.dart). Nullable:
  // "No department" until assigned.
  TextColumn get category => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{householdId, name}];

  @override
  String get tableName => 'ingredient';
}
