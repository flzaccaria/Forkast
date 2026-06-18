import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;
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
  runApp(const ForkastApp());
}

class ForkastApp extends StatelessWidget {
  const ForkastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const _BootstrapGate(),
    );
  }
}

class _Bootstrapped {
  _Bootstrapped(this.database, this.householdId);

  final AppDatabase database;
  final String householdId;
}

/// Avvia l'inizializzazione senza bloccare il primo frame: mostra uno spinner
/// mentre lavora e, se qualcosa fallisce, l'errore finisce a schermo.
class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  late final Future<_Bootstrapped> _future = _bootstrap();

  Future<_Bootstrapped> _bootstrap() async {
    if (!AppConfig.isConfigured) {
      throw StateError(
        'Configurazione mancante. Lancia con --dart-define per '
        'SUPABASE_URL, SUPABASE_ANON_KEY e POWERSYNC_URL.',
      );
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );

    final powerSyncDb = await _openPowerSyncDatabase();
    final db = AppDatabase(powerSyncDb);

    final deviceId = await ensureAnonAuth();
    final householdId = await ensureHousehold(db, deviceId);

    // Sync in background: non blocca l'avvio (local-first).
    unawaited(powerSyncDb.connect(connector: SupabaseConnector()));

    return _Bootstrapped(db, householdId);
  }

  Future<PowerSyncDatabase> _openPowerSyncDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'forkast.db');
    final db = PowerSyncDatabase(schema: forkastSchema, path: path);
    await db.initialize();
    return db;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Bootstrapped>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BootstrapErrorScreen(
            error: snapshot.error!,
            stackTrace: snapshot.stackTrace,
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        return AppScope(
          database: data.database,
          householdId: data.householdId,
          child: const AppShell(),
        );
      },
    );
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  const _BootstrapErrorScreen({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Errore di avvio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              error.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (stackTrace != null)
              SelectableText(
                stackTrace.toString(),
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
          ],
        ),
      ),
    );
  }
}
