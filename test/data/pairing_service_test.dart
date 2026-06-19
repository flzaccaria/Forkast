import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/data/pairing_service.dart';

/// La logica di abbinamento vive nelle funzioni Postgres (testabili sul DB),
/// ma la normalizzazione dell'input del codice è pura e va coperta qui.
void main() {
  group('PairingService.normalizeCode', () {
    test('rimuove spazi e trattini', () {
      expect(PairingService.normalizeCode(' 12 34-56 '), '123456');
      expect(PairingService.normalizeCode('123-456'), '123456');
    });

    test('lascia invariato un codice già pulito', () {
      expect(PairingService.normalizeCode('123456'), '123456');
    });
  });
}
