import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'data/bootstrap.dart';
import 'data/database.dart';
import 'data/powersync_connector.dart';
import 'data/powersync_schema.dart';
import 'ui/app_scope.dart';
import 'ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final powerSyncDb = await _openPowerSyncDatabase();
  final db = AppDatabase(powerSyncDb);

  final deviceId = await ensureAnonAuth();
  final householdId = await ensureHousehold(db, deviceId);

  // Avvia la sincronizzazione in background; la UI parte subito (local-first).
  unawaited(powerSyncDb.connect(connector: SupabaseConnector()));

  runApp(ForkastApp(database: db, householdId: householdId));
}

Future<PowerSyncDatabase> _openPowerSyncDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = p.join(dir.path, 'forkast.db');
  final db = PowerSyncDatabase(schema: forkastSchema, path: path);
  await db.initialize();
  return db;
}

class ForkastApp extends StatelessWidget {
  const ForkastApp({
    super.key,
    required this.database,
    required this.householdId,
  });

  final AppDatabase database;
  final String householdId;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      database: database,
      householdId: householdId,
      child: MaterialApp(
        title: 'Forkast',
        theme: ThemeData(
          colorSchemeSeed: Colors.green,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.green,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const AppShell(),
      ),
    );
  }
}
