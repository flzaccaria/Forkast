import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/powersync_connector.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CrudEntry _put(int clientId, String table, String id,
        [Map<String, dynamic>? data]) =>
    CrudEntry(clientId, UpdateType.put, table, id, null, data ?? {'name': id});

CrudEntry _del(int clientId, String table, String id) =>
    CrudEntry(clientId, UpdateType.delete, table, id, null, null);

CrudEntry _patch(int clientId, String table, String id,
        Map<String, dynamic> data) =>
    CrudEntry(clientId, UpdateType.patch, table, id, null, data);

CrudBatch _batch(List<CrudEntry> ops, {required _Tracker t}) => CrudBatch(
      crud: ops,
      haveMore: false,
      complete: ({String? writeCheckpoint}) async {
        t.completed = true;
      },
    );

/// Records every REST call the sink receives.
class _MockSink implements CrudUploadSink {
  final upsertCalls = <(String, List<Map<String, dynamic>>)>[];
  final deleteCalls = <(String, List<String>)>[];
  final patchCalls = <(String, String, Map<String, dynamic>)>[];

  /// IDs that trigger a fatal error on upsert/delete/patch.
  final Set<String> fatalIds;

  /// IDs that trigger a transient error.
  final Set<String> transientIds;

  _MockSink({this.fatalIds = const {}, this.transientIds = const {}});

  void _checkRow(String id) {
    if (fatalIds.contains(id)) {
      throw PostgrestException(
          message: 'constraint violation on $id', code: '23502');
    }
    if (transientIds.contains(id)) {
      throw PostgrestException(message: 'timeout on $id', code: '08001');
    }
  }

  @override
  Future<void> upsertRows(
      String table, List<Map<String, dynamic>> rows) async {
    upsertCalls.add((table, rows));
    for (final row in rows) {
      _checkRow(row['id'] as String);
    }
  }

  @override
  Future<void> deleteRows(String table, List<String> ids) async {
    deleteCalls.add((table, ids));
    for (final id in ids) {
      _checkRow(id);
    }
  }

  @override
  Future<void> patchRow(
      String table, String id, Map<String, dynamic> data) async {
    patchCalls.add((table, id, data));
    _checkRow(id);
  }
}

class _Tracker {
  bool completed = false;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('isFatalUploadError', () {
    PostgrestException ex(String? code) =>
        PostgrestException(message: 'test', code: code);

    test('class 22 (data exception) is fatal', () {
      expect(isFatalUploadError(ex('22003')), true);
      expect(isFatalUploadError(ex('22P02')), true);
    });

    test('class 23 (integrity constraint) is fatal', () {
      expect(isFatalUploadError(ex('23505')), true);
      expect(isFatalUploadError(ex('23503')), true);
      expect(isFatalUploadError(ex('23514')), true);
    });

    test('42501 (insufficient privilege / RLS denial) is fatal', () {
      expect(isFatalUploadError(ex('42501')), true);
    });

    test('401 (HTTP unauthorized) is fatal', () {
      expect(isFatalUploadError(ex('401')), true);
    });

    test('403 (HTTP forbidden) is fatal', () {
      expect(isFatalUploadError(ex('403')), true);
    });

    test('other class-42 codes are NOT fatal (may indicate a code bug)', () {
      expect(isFatalUploadError(ex('42P01')), false);
      expect(isFatalUploadError(ex('42601')), false);
    });

    test('null code is transient (network error)', () {
      expect(isFatalUploadError(ex(null)), false);
    });

    test('unknown code is transient (retryable)', () {
      expect(isFatalUploadError(ex('08001')), false);
      expect(isFatalUploadError(ex('57014')), false);
      expect(isFatalUploadError(ex('500')), false);
    });
  });

  group('processCrudBatch — batching', () {
    test('100 upserts on the same table produce 1 request', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        for (var i = 0; i < 100; i++) _put(i, 'ingredient', 'i-$i'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.upsertCalls, hasLength(1));
      expect(sink.upsertCalls.first.$1, 'ingredient');
      expect(sink.upsertCalls.first.$2, hasLength(100));
      expect(t.completed, true);
    });

    test('deletes on the same table produce 1 request', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        for (var i = 0; i < 10; i++) _del(i, 'dish_ingredient', 'di-$i'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.deleteCalls, hasLength(1));
      expect(sink.deleteCalls.first.$2, hasLength(10));
      expect(t.completed, true);
    });

    test('ops on different tables produce one request per table', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        _put(1, 'ingredient', 'i-1'),
        _put(2, 'ingredient', 'i-2'),
        _put(3, 'dish', 'd-1'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.upsertCalls, hasLength(2));
      final tables = sink.upsertCalls.map((c) => c.$1).toList();
      expect(tables, ['ingredient', 'dish']);
      expect(t.completed, true);
    });

    test('FK order: parent tables upserted before children', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        _put(1, 'dish_ingredient', 'di-1'),
        _put(2, 'dish', 'd-1'),
        _put(3, 'ingredient', 'i-1'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      final tables = sink.upsertCalls.map((c) => c.$1).toList();
      expect(tables, ['ingredient', 'dish', 'dish_ingredient']);
    });

    test('FK order: child tables deleted before parents', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        _del(1, 'dish', 'd-1'),
        _del(2, 'dish_ingredient', 'di-1'),
        _del(3, 'ingredient', 'i-1'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      final tables = sink.deleteCalls.map((c) => c.$1).toList();
      expect(tables, ['dish_ingredient', 'dish', 'ingredient']);
    });

    test('mixed ops: upserts before deletes', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        _del(1, 'ingredient', 'i-old'),
        _put(2, 'ingredient', 'i-new'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.upsertCalls, hasLength(1));
      expect(sink.deleteCalls, hasLength(1));
      expect(t.completed, true);
    });

    test('patches stay per-row', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [
        _patch(1, 'ingredient', 'i-1', {'name': 'A'}),
        _patch(2, 'ingredient', 'i-2', {'name': 'B'}),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.patchCalls, hasLength(2));
      expect(t.completed, true);
    });
  });

  group('processCrudBatch — error handling', () {
    test('batch with one fatal row: valid rows uploaded, fatal skipped',
        () async {
      final sink = _MockSink(fatalIds: {'i-bad'});
      final t = _Tracker();
      final ops = [
        for (var i = 0; i < 5; i++) _put(i, 'ingredient', 'i-$i'),
        _put(99, 'ingredient', 'i-bad'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      // First call was the bulk (6 rows) → failed fatally.
      // Then 6 per-row retries; 5 succeed, 1 (i-bad) is skipped.
      expect(sink.upsertCalls, hasLength(7)); // 1 bulk + 6 per-row
      expect(t.completed, true);
    });

    test('transient error rethrows and does not complete', () async {
      final sink = _MockSink(transientIds: {'i-1'});
      final t = _Tracker();
      final ops = [_put(1, 'ingredient', 'i-1')];

      await expectLater(
        () => processCrudBatch(_batch(ops, t: t), sink),
        throwsA(isA<PostgrestException>()),
      );
      expect(t.completed, false);
    });

    test('fatal patch is skipped, others proceed', () async {
      final sink = _MockSink(fatalIds: {'i-bad'});
      final t = _Tracker();
      final ops = [
        _patch(1, 'ingredient', 'i-bad', {'name': 'X'}),
        _patch(2, 'ingredient', 'i-ok', {'name': 'Y'}),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.patchCalls, hasLength(2));
      expect(t.completed, true);
    });

    test('fatal delete is skipped via per-row fallback', () async {
      final sink = _MockSink(fatalIds: {'i-bad'});
      final t = _Tracker();
      final ops = [
        _del(1, 'ingredient', 'i-ok'),
        _del(2, 'ingredient', 'i-bad'),
      ];

      await processCrudBatch(_batch(ops, t: t), sink);

      // 1 bulk (2 ids) → fatal → 2 per-row; 1 succeeds, 1 skipped.
      expect(sink.deleteCalls, hasLength(3));
      expect(t.completed, true);
    });

    test('all ops valid — all uploaded and batch completes', () async {
      final sink = _MockSink();
      final t = _Tracker();
      final ops = [_put(1, 'dish', 'd-1'), _put(2, 'dish', 'd-2')];

      await processCrudBatch(_batch(ops, t: t), sink);

      expect(sink.upsertCalls, hasLength(1));
      expect(sink.upsertCalls.first.$2, hasLength(2));
      expect(t.completed, true);
    });
  });
}
