import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/powersync_connector.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

CrudEntry _entry(int clientId, String table, String id) => CrudEntry(
      clientId,
      UpdateType.put,
      table,
      id,
      null,
      {'name': 'test'},
    );

void main() {
  group('isFatalUploadError', () {
    PostgrestException ex(String? code) =>
        PostgrestException(message: 'test', code: code);

    test('class 22 (data exception) is fatal', () {
      expect(isFatalUploadError(ex('22003')), true); // numeric_value_out_of_range
      expect(isFatalUploadError(ex('22P02')), true); // invalid_text_representation
    });

    test('class 23 (integrity constraint) is fatal', () {
      expect(isFatalUploadError(ex('23505')), true); // unique_violation
      expect(isFatalUploadError(ex('23503')), true); // foreign_key_violation
      expect(isFatalUploadError(ex('23514')), true); // check_violation
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
      expect(isFatalUploadError(ex('42P01')), false); // undefined_table
      expect(isFatalUploadError(ex('42601')), false); // syntax_error
    });

    test('null code is transient (network error)', () {
      expect(isFatalUploadError(ex(null)), false);
    });

    test('unknown code is transient (retryable)', () {
      expect(isFatalUploadError(ex('08001')), false); // connection_exception
      expect(isFatalUploadError(ex('57014')), false); // query_canceled
      expect(isFatalUploadError(ex('500')), false);   // HTTP 500
    });
  });

  group('processCrudBatch', () {
    test('fatal op is skipped, valid op is uploaded, batch completes', () async {
      final fatalOp = _entry(1, 'household', 'h-1');
      final validOp = _entry(2, 'ingredient', 'i-1');
      final uploaded = <String>[];
      var completed = false;

      final batch = CrudBatch(
        crud: [fatalOp, validOp],
        haveMore: false,
        complete: ({String? writeCheckpoint}) async {
          completed = true;
        },
      );

      Future<void> uploader(CrudEntry op) async {
        if (op.clientId == 1) {
          throw const PostgrestException(message: 'RLS denied', code: '42501');
        }
        uploaded.add('${op.table}/${op.id}');
      }

      await processCrudBatch(batch, uploader);

      expect(uploaded, ['ingredient/i-1']);
      expect(completed, true);
    });

    test('transient error rethrows and does not complete the batch', () async {
      final transientOp = _entry(1, 'household', 'h-1');
      final validOp = _entry(2, 'ingredient', 'i-1');
      var completed = false;

      final batch = CrudBatch(
        crud: [transientOp, validOp],
        haveMore: false,
        complete: ({String? writeCheckpoint}) async {
          completed = true;
        },
      );

      Future<void> uploader(CrudEntry op) async {
        if (op.clientId == 1) {
          throw const PostgrestException(message: 'timeout', code: '08001');
        }
      }

      expect(
        () => processCrudBatch(batch, uploader),
        throwsA(isA<PostgrestException>()),
      );
      expect(completed, false);
    });

    test('all ops valid — all uploaded and batch completes', () async {
      final ops = [_entry(1, 'dish', 'd-1'), _entry(2, 'dish', 'd-2')];
      final uploaded = <String>[];
      var completed = false;

      final batch = CrudBatch(
        crud: ops,
        haveMore: false,
        complete: ({String? writeCheckpoint}) async {
          completed = true;
        },
      );

      Future<void> uploader(CrudEntry op) async {
        uploaded.add('${op.table}/${op.id}');
      }

      await processCrudBatch(batch, uploader);

      expect(uploaded, ['dish/d-1', 'dish/d-2']);
      expect(completed, true);
    });
  });
}
