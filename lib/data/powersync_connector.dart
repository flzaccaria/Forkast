import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

/// Whether a PostgREST error should discard the operation rather than retry.
///
/// Fatal errors are permanent: retrying won't fix them and would block the
/// entire upload queue. This includes:
/// - Class 22: data exception (bad value for column type, etc.)
/// - Class 23: integrity constraint violation (unique, FK, check)
/// - 42501: insufficient privilege (RLS denial — the operation is structurally
///   forbidden, e.g. a stale household write that RLS rejects)
/// - 401 / 403: HTTP-level auth/permission errors from PostgREST (JWT expired
///   or request denied before reaching Postgres)
bool isFatalUploadError(PostgrestException e) {
  final code = e.code ?? '';
  return code.startsWith('22') ||
      code.startsWith('23') ||
      code == '42501' ||
      code == '401' ||
      code == '403';
}

/// Connects PowerSync to Supabase: provides the credentials (anon token)
/// and flushes the upload queue to the Postgres tables.
class SupabaseConnector extends PowerSyncBackendConnector {
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;
    return PowerSyncCredentials(
      endpoint: AppConfig.powersyncUrl,
      token: session.accessToken,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final batch = await database.getCrudBatch();
    if (batch == null) return;

    final rest = Supabase.instance.client;
    try {
      for (final op in batch.crud) {
        final table = rest.from(op.table);
        switch (op.op) {
          case UpdateType.put:
            final data = Map<String, dynamic>.of(op.opData ?? {});
            data['id'] = op.id;
            await table.upsert(data);
          case UpdateType.patch:
            await table.update(op.opData ?? {}).eq('id', op.id);
          case UpdateType.delete:
            await table.delete().eq('id', op.id);
        }
      }
      await batch.complete();
    } on PostgrestException catch (e) {
      if (isFatalUploadError(e)) {
        await batch.complete();
      } else {
        rethrow;
      }
    }
  }
}
