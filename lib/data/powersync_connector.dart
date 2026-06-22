import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
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

/// Executes a single CRUD operation against Supabase.
///
/// Extracted so that tests can replace it without a real Supabase client.
typedef CrudUploader = Future<void> Function(CrudEntry op);

/// Default [CrudUploader] that writes to [Supabase.instance.client].
@visibleForTesting
Future<void> defaultCrudUploader(CrudEntry op) async {
  final table = Supabase.instance.client.from(op.table);
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

/// Processes every op in [batch] through [uploader], skipping fatal errors.
///
/// Fatal [PostgrestException]s (see [isFatalUploadError]) are logged and
/// skipped so the remaining ops in the batch still get a chance.
/// Transient errors rethrow immediately — PowerSync will retry the batch.
/// Calls [batch.complete()] once after all ops have been attempted.
@visibleForTesting
Future<void> processCrudBatch(CrudBatch batch, CrudUploader uploader) async {
  for (final op in batch.crud) {
    try {
      await uploader(op);
    } on PostgrestException catch (e) {
      if (isFatalUploadError(e)) {
        developer.log(
          'Skipping fatally rejected op ${op.op.toJson()} '
          '${op.table}/${op.id}: ${e.code} – ${e.message}',
          name: 'SupabaseConnector',
        );
        continue;
      }
      rethrow;
    }
  }
  await batch.complete();
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
    await processCrudBatch(batch, defaultCrudUploader);
  }
}
