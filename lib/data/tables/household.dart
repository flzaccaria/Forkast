import 'package:drift/drift.dart';

class Households extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  IntColumn get defaultGuests => integer().withDefault(const Constant(4))();
  IntColumn get weekStartDay => integer().withDefault(const Constant(0))();
  BoolColumn get autoRegen => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'household';
}
