import 'package:drift/drift.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get name => text()();
  TextColumn get tagGroup => text().named('group')();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{householdId, name}];
}
