import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'core/clear_url_query.dart';
import 'core/locale_provider.dart';
import 'core/seed_name_resolver.dart';
import 'data/bootstrap.dart';
import 'data/database.dart';
import 'data/open_database.dart';
import 'data/powersync_connector.dart';
import 'data/repositories/ingredient_repository.dart';
import 'data/seed_catalog.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/app_scope.dart';
import 'ui/app_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final localeNotifier = LocaleNotifier(prefs);
  runApp(ForkastApp(localeNotifier: localeNotifier));
}

class ForkastApp extends StatelessWidget {
  const ForkastApp({super.key, required this.localeNotifier});

  final LocaleNotifier localeNotifier;

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      notifier: localeNotifier,
      child: ListenableBuilder(
        listenable: localeNotifier,
        builder: (context, _) => _BootstrapGate(
          localeNotifier: localeNotifier,
        ),
      ),
    );
  }
}

class _Bootstrapped {
  _Bootstrapped(this.database, this.householdId);

  final AppDatabase database;
  final String householdId;
}

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate({required this.localeNotifier});

  final LocaleNotifier localeNotifier;

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  late final Future<_Bootstrapped> _future = _bootstrap();

  String? _householdOverride;

  final String? _pairingCode = Uri.base.queryParameters['code'];
  bool _urlCleared = false;

  Future<_Bootstrapped> _bootstrap() async {
    if (!AppConfig.isConfigured) {
      throw StateError(
        'Missing configuration. Launch with --dart-define for '
        'SUPABASE_URL, SUPABASE_ANON_KEY and POWERSYNC_URL.',
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

    unawaited(IngredientRepository(db, householdId).migrateUnitsToEnum());

    unawaited(seedCatalogIfNeeded(db, householdId));
    unawaited(backfillSeedKeys(db, householdId));
    unawaited(backfillRoundingKind(db, householdId));

    await SeedNameResolver.instance.load();

    return _Bootstrapped(db, householdId);
  }

  MaterialApp _materialApp({required Widget home}) {
    return MaterialApp(
      title: 'Forkast',
      theme: forkastLightTheme,
      darkTheme: forkastDarkTheme,
      locale: widget.localeNotifier.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Bootstrapped>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _materialApp(
            home: _BootstrapErrorScreen(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace,
            ),
          );
        }
        if (!snapshot.hasData) {
          return _materialApp(
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final data = snapshot.data!;
        if (_pairingCode != null && !_urlCleared) {
          _urlCleared = true;
          clearUrlQuery();
        }
        return AppScope(
          database: data.database,
          householdId: _householdOverride ?? data.householdId,
          onHouseholdChanged: (id) =>
              setState(() => _householdOverride = id),
          child: _materialApp(
            home: AppShell(pairingCode: _pairingCode),
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.bootstrapError)),
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
