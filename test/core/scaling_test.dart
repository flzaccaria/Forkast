import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/scaling.dart';

void main() {
  group('scaleQty', () {
    test('4 guests = identity', () {
      expect(scaleQty(qtyBase4: 600, guests: 4), 600);
    });

    test('6 guests = ×1.5', () {
      expect(scaleQty(qtyBase4: 600, guests: 6), 900);
    });

    test('2 guests = half', () {
      expect(scaleQty(qtyBase4: 600, guests: 2), 300);
    });

    test('1 guest = ×0.25', () {
      expect(scaleQty(qtyBase4: 4, guests: 1), 1);
    });

    test('8 guests = double', () {
      expect(scaleQty(qtyBase4: 100, guests: 8), 200);
    });
  });

  group('roundForUnit', () {
    test('pieces round up', () {
      expect(roundForUnit(1.5, 'pz'), 2);
      expect(roundForUnit(1.1, 'pz'), 2);
      expect(roundForUnit(3.0, 'pz'), 3);
    });

    test('grams round to the upper half', () {
      expect(roundForUnit(900, 'g'), 900);
      expect(roundForUnit(900.1, 'g'), 900.5);
      expect(roundForUnit(900.3, 'g'), 900.5);
      expect(roundForUnit(900.6, 'g'), 901);
    });

    test('whole units recognized', () {
      expect(roundForUnit(2.3, 'fetta'), 3);
      expect(roundForUnit(2.3, 'spicchio'), 3);
    });
  });

  group('scaleAndRound', () {
    test('hamburger example: 4 buns for 6 people', () {
      expect(scaleAndRound(qtyBase4: 4, guests: 6, unit: 'pz'), 6);
    });

    test('salad example: 1 for 6 people', () {
      expect(scaleAndRound(qtyBase4: 1, guests: 6, unit: 'pz'), 2);
    });

    test('meat example: 600g for 6 people', () {
      expect(scaleAndRound(qtyBase4: 600, guests: 6, unit: 'g'), 900);
    });

    test('fresh tomatoes: 4 pcs for 6 people', () {
      expect(scaleAndRound(qtyBase4: 4, guests: 6, unit: 'pz'), 6);
    });

    test('fresh tomatoes: 2 pcs for 2 people', () {
      expect(scaleAndRound(qtyBase4: 2, guests: 2, unit: 'pz'), 1);
    });
  });
}
