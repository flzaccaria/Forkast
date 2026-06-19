import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import 'powersync_schema.dart';

Future<PowerSyncDatabase> openPowerSyncDatabase() async {
  final db = PowerSyncDatabase(schema: forkastSchema, path: 'forkast.db');
  await db.initialize();
  return db;
}
