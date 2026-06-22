import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'core/clear_url_query.dart';
import 'data/bootstrap.dart';
import 'data/database.dart';
import 'data/open_database.dart';
import 'data/powersync_connector.dart';
import 'ui/app_scope.dart';
import 'ui/app_shell.dart';

final _theme = ThemeData(
  colorSchemeSeed: Colors.green,
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  colorSchemeSeed: Colors.green,
  brightness: Brightness.dark,
  useMaterial3: true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ForkastApp());
}

class ForkastApp extends StatelessWidget {
  const ForkastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BootstrapGate();
  }
}

class _Bootstrapped {
  _Bootstrapped(this.database, this.householdId);

  final AppDatabase database;
  final String householdId;
}

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  late final Future<_Bootstrapped> _future = _bootstrap();

  /// Active household overridden at runtime (e.g. after pairing). When
  /// null, the one determined at bootstrap is used.
  String? _householdOverride;

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

    final powerSyncDb = await openPowerSyncDatabase();
    final db = AppDatabase(powerSyncDb);

    final deviceId = await ensureAnonAuth();
    final householdId = await ensureHousehold(db, deviceId);

    unawaited(powerSyncDb.connect(connector: SupabaseConnector()));

    return _Bootstrapped(db, householdId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Bootstrapped>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            title: 'Forkast',
            theme: _theme,
            darkTheme: _darkTheme,
            home: _BootstrapErrorScreen(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace,
            ),
          );
        }
        if (!snapshot.hasData) {
          return MaterialApp(
            title: 'Forkast',
            theme: _theme,
            darkTheme: _darkTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final data = snapshot.data!;
        final pairingCode = Uri.base.queryParameters['code'];
        if (pairingCode != null) clearUrlQuery();
        return AppScope(
          database: data.database,
          householdId: _householdOverride ?? data.householdId,
          onHouseholdChanged: (id) =>
              setState(() => _householdOverride = id),
          child: MaterialApp(
            title: 'Forkast',
            theme: _theme,
            darkTheme: _darkTheme,
            home: AppShell(pairingCode: pairingCode),
          ),
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
