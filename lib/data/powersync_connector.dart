import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';

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
      // "Fatal" errors (e.g. constraint violation): discard the operation,
      // otherwise the queue would stay blocked forever. Transient errors
      // (network) are rethrown so PowerSync retries.
      final fatal = e.code != null && e.code!.startsWith('22') ||
          e.code != null && e.code!.startsWith('23');
      if (fatal) {
        await batch.complete();
      } else {
        rethrow;
      }
    }
  }
}
