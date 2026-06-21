import 'package:supabase_flutter/supabase_flutter.dart';

import 'database.dart';

/// Ensures an anonymous Supabase session. The first launch requires network;
/// afterwards, the session is persisted and startup works offline too.
Future<String> ensureAnonAuth() async {
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    await auth.signInAnonymously();
  }
  return auth.currentUser!.id;
}

/// Creates household + membership via the server-side `SECURITY DEFINER`
/// function `bootstrap_household()` (00006), consistent with the pairing flow
/// (00002). The RPC is idempotent: if the device already has a household on
/// the server, it returns the existing id without creating anything.
///
/// **Local-first check**: if sync has already delivered a membership row for
/// this device, it is returned immediately without network (offline-fast
/// path for every launch after the first).
///
/// **Offline fallback**: if the RPC fails due to network, a
/// [BootstrapException] is thrown so the caller can show an error and retry
/// on next app restart. The first launch always requires network (anonymous
/// sign-in), so this only triggers if the connection drops between auth and
/// the RPC call.
///
/// The household and membership rows are NOT written locally: they arrive on
/// the device via PowerSync sync (read), avoiding the RLS chicken-and-egg
/// that blocked the old local-insert approach.
Future<String> ensureHousehold(AppDatabase db, String deviceId) async {
  final existing = await (db.select(db.memberships)
        ..where((m) => m.deviceId.equals(deviceId)))
      .getSingleOrNull();
  if (existing != null) return existing.householdId;

  try {
    final res = await Supabase.instance.client.rpc('bootstrap_household');
    return res as String;
  } on PostgrestException catch (e) {
    if (e.message.contains('not_authenticated')) {
      throw BootstrapException(
        'Sessione non valida. Effettua nuovamente l\'accesso.',
      );
    }
    throw BootstrapException(
      'Errore dal server durante la creazione dell\'household: ${e.message}',
    );
  } on Exception {
    throw BootstrapException(
      'Impossibile contattare il server. '
      'Controlla la connessione e riavvia l\'app.',
    );
  }
}

class BootstrapException implements Exception {
  BootstrapException(this.message);
  final String message;

  @override
  String toString() => message;
}
