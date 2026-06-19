import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/pairing_service.dart';

/// The pairing logic lives in the Postgres functions (testable on the DB),
/// but the normalization of the code input is pure and must be covered here.
void main() {
  group('PairingService.normalizeCode', () {
    test('removes spaces and hyphens', () {
      expect(PairingService.normalizeCode(' 12 34-56 '), '123456');
      expect(PairingService.normalizeCode('123-456'), '123456');
    });

    test('leaves an already clean code unchanged', () {
      expect(PairingService.normalizeCode('123456'), '123456');
    });
  });
}
