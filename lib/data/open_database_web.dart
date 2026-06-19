import 'package:powersync/powersync.dart'
    show PowerSyncDatabase, WebSqliteOpenFactory;

import 'powersync_schema.dart';

Future<PowerSyncDatabase> openPowerSyncDatabase() async {
  final db = PowerSyncDatabase.withFactory(
    WebSqliteOpenFactory(path: 'forkast.db'),
    schema: forkastSchema,
  );
  await db.initialize();
  return db;
}
