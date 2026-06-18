import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/scaling.dart';

void main() {
  group('scaleQty', () {
    test('4 commensali = identità', () {
      expect(scaleQty(qtyBase4: 600, guests: 4), 600);
    });

    test('6 commensali = ×1.5', () {
      expect(scaleQty(qtyBase4: 600, guests: 6), 900);
    });

    test('2 commensali = metà', () {
      expect(scaleQty(qtyBase4: 600, guests: 2), 300);
    });

    test('1 commensale = ×0.25', () {
      expect(scaleQty(qtyBase4: 4, guests: 1), 1);
    });

    test('8 commensali = doppio', () {
      expect(scaleQty(qtyBase4: 100, guests: 8), 200);
    });
  });

  group('roundForUnit', () {
    test('pezzi arrotonda per eccesso', () {
      expect(roundForUnit(1.5, 'pz'), 2);
      expect(roundForUnit(1.1, 'pz'), 2);
      expect(roundForUnit(3.0, 'pz'), 3);
    });

    test('grammi arrotonda al mezzo superiore', () {
      expect(roundForUnit(900, 'g'), 900);
      expect(roundForUnit(900.1, 'g'), 900.5);
      expect(roundForUnit(900.3, 'g'), 900.5);
      expect(roundForUnit(900.6, 'g'), 901);
    });

    test('unità intere riconosciute', () {
      expect(roundForUnit(2.3, 'fetta'), 3);
      expect(roundForUnit(2.3, 'spicchio'), 3);
    });
  });

  group('scaleAndRound', () {
    test('esempio hamburger: 4 panini per 6 persone', () {
      expect(scaleAndRound(qtyBase4: 4, guests: 6, unit: 'pz'), 6);
    });

    test('esempio insalata: 1 per 6 persone', () {
      expect(scaleAndRound(qtyBase4: 1, guests: 6, unit: 'pz'), 2);
    });

    test('esempio carne: 600g per 6 persone', () {
      expect(scaleAndRound(qtyBase4: 600, guests: 6, unit: 'g'), 900);
    });

    test('pomodori freschi: 4 pz per 6 persone', () {
      expect(scaleAndRound(qtyBase4: 4, guests: 6, unit: 'pz'), 6);
    });

    test('pomodori freschi: 2 pz per 2 persone', () {
      expect(scaleAndRound(qtyBase4: 2, guests: 2, unit: 'pz'), 1);
    });
  });
}
