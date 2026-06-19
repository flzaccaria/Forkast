import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import 'powersync_schema.dart';

Future<PowerSyncDatabase> openPowerSyncDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = p.join(dir.path, 'forkast.db');
  final db = PowerSyncDatabase(schema: forkastSchema, path: path);
  await db.initialize();
  return db;
}
