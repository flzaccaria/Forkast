import 'package:drift/drift.dart';

class Memberships extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text()();
  TextColumn get deviceId => text()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  DateTimeColumn get joinedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'membership';
}
