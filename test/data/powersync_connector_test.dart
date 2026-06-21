import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/powersync_connector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
