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

// ---------------------------------------------------------------------------
// Batched CRUD sink
// ---------------------------------------------------------------------------

/// Abstraction over Supabase REST calls, enabling bulk operations and testing.
abstract class CrudUploadSink {
  Future<void> upsertRows(String table, List<Map<String, dynamic>> rows);
  Future<void> deleteRows(String table, List<String> ids);
  Future<void> patchRow(String table, String id, Map<String, dynamic> data);
}

/// Default [CrudUploadSink] backed by the live Supabase client.
class SupabaseCrudSink implements CrudUploadSink {
  @override
  Future<void> upsertRows(String table, List<Map<String, dynamic>> rows) =>
      Supabase.instance.client.from(table).upsert(rows);

  @override
  Future<void> deleteRows(String table, List<String> ids) =>
      Supabase.instance.client.from(table).delete().inFilter('id', ids);

  @override
  Future<void> patchRow(String table, String id, Map<String, dynamic> data) =>
      Supabase.instance.client.from(table).update(data).eq('id', id);
}

// ---------------------------------------------------------------------------
// Table ordering (FK constraints)
// ---------------------------------------------------------------------------

const _tableOrder = [
  'household',
  'membership',
  'ingredient',
  'tag',
  'dish',
  'dish_tag',
  'dish_ingredient',
  'week_plan',
  'plan_day',
  'plan_day_dish',
  'shopping_list',
  'list_generated_row',
  'list_override',
  'list_manual_item',
  'list_check',
];

int _tableIndex(String table) {
  final i = _tableOrder.indexOf(table);
  return i >= 0 ? i : _tableOrder.length;
}

// ---------------------------------------------------------------------------
// Batch processing
// ---------------------------------------------------------------------------

/// Groups ops by table+type, executes bulk requests respecting FK order,
/// and isolates fatal rows without blocking the queue.
///
/// Upserts and patches run in parent→child order; deletes run in
/// child→parent order. Calls [batch.complete()] once after all ops.
@visibleForTesting
Future<void> processCrudBatch(CrudBatch batch, CrudUploadSink sink) async {
  final upserts = <String, List<CrudEntry>>{};
  final patches = <String, List<CrudEntry>>{};
  final deletes = <String, List<CrudEntry>>{};

  for (final op in batch.crud) {
    switch (op.op) {
      case UpdateType.put:
        (upserts[op.table] ??= []).add(op);
      case UpdateType.patch:
        (patches[op.table] ??= []).add(op);
      case UpdateType.delete:
        (deletes[op.table] ??= []).add(op);
    }
  }

  // Upserts + patches: parent tables first.
  final upTables = {...upserts.keys, ...patches.keys}.toList()
    ..sort((a, b) => _tableIndex(a).compareTo(_tableIndex(b)));

  for (final table in upTables) {
    final ups = upserts[table];
    if (ups != null) await _upsertBatch(sink, table, ups);
    final pats = patches[table];
    if (pats != null) await _patchBatch(sink, table, pats);
  }

  // Deletes: child tables first (reverse FK order).
  final delTables = deletes.keys.toList()
    ..sort((a, b) => _tableIndex(b).compareTo(_tableIndex(a)));

  for (final table in delTables) {
    await _deleteBatch(sink, table, deletes[table]!);
  }

  await batch.complete();
}

/// Bulk upsert; on fatal error, falls back to per-row to isolate the bad row.
Future<void> _upsertBatch(
    CrudUploadSink sink, String table, List<CrudEntry> entries) async {
  final rows = entries.map(_entryToRow).toList();
  try {
    await sink.upsertRows(table, rows);
  } on PostgrestException catch (e) {
    if (!isFatalUploadError(e)) rethrow;
    for (var i = 0; i < entries.length; i++) {
      try {
        await sink.upsertRows(table, [rows[i]]);
      } on PostgrestException catch (rowErr) {
        if (isFatalUploadError(rowErr)) {
          _logSkipped(entries[i], rowErr);
          continue;
        }
        rethrow;
      }
    }
  }
}

/// Bulk delete; same fallback strategy as upsert.
Future<void> _deleteBatch(
    CrudUploadSink sink, String table, List<CrudEntry> entries) async {
  final ids = entries.map((e) => e.id).toList();
  try {
    await sink.deleteRows(table, ids);
  } on PostgrestException catch (e) {
    if (!isFatalUploadError(e)) rethrow;
    for (final entry in entries) {
      try {
        await sink.deleteRows(table, [entry.id]);
      } on PostgrestException catch (rowErr) {
        if (isFatalUploadError(rowErr)) {
          _logSkipped(entry, rowErr);
          continue;
        }
        rethrow;
      }
    }
  }
}

/// Patches stay per-row (partial update can't be grouped safely).
Future<void> _patchBatch(
    CrudUploadSink sink, String table, List<CrudEntry> entries) async {
  for (final entry in entries) {
    try {
      await sink.patchRow(table, entry.id, entry.opData ?? {});
    } on PostgrestException catch (e) {
      if (isFatalUploadError(e)) {
        _logSkipped(entry, e);
        continue;
      }
      rethrow;
    }
  }
}

Map<String, dynamic> _entryToRow(CrudEntry e) {
  final data = Map<String, dynamic>.of(e.opData ?? {});
  data['id'] = e.id;
  return data;
}

void _logSkipped(CrudEntry op, PostgrestException e) {
  developer.log(
    'Skipping fatally rejected op ${op.op.toJson()} '
    '${op.table}/${op.id}: ${e.code} – ${e.message}',
    name: 'SupabaseConnector',
  );
}

// ---------------------------------------------------------------------------
// Connector
// ---------------------------------------------------------------------------

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
    await processCrudBatch(batch, SupabaseCrudSink());
  }
}
