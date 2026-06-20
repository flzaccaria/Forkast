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
    test('whole rounds up to integer', () {
      expect(roundForUnit(1.5, 'whole', 'pz'), 2);
      expect(roundForUnit(1.1, 'whole', 'uovo'), 2);
      expect(roundForUnit(3.0, 'whole', 'pz'), 3);
    });

    test('weight in grams rounds up to the nearest 10', () {
      expect(roundForUnit(900, 'weight', 'g'), 900);
      expect(roundForUnit(900.1, 'weight', 'g'), 910);
      expect(roundForUnit(895, 'weight', 'g'), 900);
      expect(roundForUnit(891, 'weight', 'g'), 900);
      expect(roundForUnit(901, 'weight', 'g'), 910);
    });

    test('weight in kg rounds up to the nearest 0.1', () {
      expect(roundForUnit(1.0, 'weight', 'kg'), 1.0);
      expect(roundForUnit(1.01, 'weight', 'kg'), 1.1);
      expect(roundForUnit(1.1, 'weight', 'kg'), 1.1);
      expect(roundForUnit(1.15, 'weight', 'kg'), 1.2);
    });

    test('volume in ml rounds up to the nearest 10', () {
      expect(roundForUnit(250, 'volume', 'ml'), 250);
      expect(roundForUnit(251, 'volume', 'ml'), 260);
      expect(roundForUnit(245, 'volume', 'ml'), 250);
    });

    test('volume in l rounds up to the nearest 0.1', () {
      expect(roundForUnit(0.5, 'volume', 'l'), 0.5);
      expect(roundForUnit(0.51, 'volume', 'l'), 0.6);
      expect(roundForUnit(0.3, 'volume', 'l'), 0.3);
    });

    test('volume in cl/dl rounds up to the nearest 0.1', () {
      expect(roundForUnit(2.5, 'volume', 'cl'), 2.5);
      expect(roundForUnit(2.51, 'volume', 'cl'), 2.6);
      expect(roundForUnit(1.05, 'volume', 'dl'), 1.1);
    });

    test('unknown rounding_kind asserts in debug mode', () {
      expect(
        () => roundForUnit(1.1, 'unknown', 'xyz'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('scaleAndRound', () {
    test('hamburger example: 4 buns for 6 people', () {
      expect(scaleAndRound(
          qtyBase4: 4, guests: 6, roundingKind: 'whole', unit: 'pz'), 6);
    });

    test('salad example: 1 for 6 people', () {
      expect(scaleAndRound(
          qtyBase4: 1, guests: 6, roundingKind: 'whole', unit: 'pz'), 2);
    });

    test('meat example: 600g for 6 people → 900g (exact, no rounding)', () {
      expect(scaleAndRound(
          qtyBase4: 600, guests: 6, roundingKind: 'weight', unit: 'g'), 900);
    });

    test('meat example: 600g for 5 people → 750g → 750g', () {
      expect(scaleAndRound(
          qtyBase4: 600, guests: 5, roundingKind: 'weight', unit: 'g'), 750);
    });

    test('meat example: 600g for 3 people → 450g → 450g', () {
      expect(scaleAndRound(
          qtyBase4: 600, guests: 3, roundingKind: 'weight', unit: 'g'), 450);
    });

    test('meat example: 600g for 7 people → 1050g → 1050g', () {
      expect(scaleAndRound(
          qtyBase4: 600, guests: 7, roundingKind: 'weight', unit: 'g'), 1050);
    });

    test('fresh tomatoes: 4 pcs for 6 people', () {
      expect(scaleAndRound(
          qtyBase4: 4, guests: 6, roundingKind: 'whole', unit: 'pz'), 6);
    });

    test('fresh tomatoes: 2 pcs for 2 people', () {
      expect(scaleAndRound(
          qtyBase4: 2, guests: 2, roundingKind: 'whole', unit: 'pz'), 1);
    });

    test('1.5 kg rounds to 0.1 → 1.5 kg (exact)', () {
      expect(scaleAndRound(
          qtyBase4: 1, guests: 6, roundingKind: 'weight', unit: 'kg'), 1.5);
    });

    test('milk 500 ml for 3 people → 375 ml → 380 ml', () {
      expect(scaleAndRound(
          qtyBase4: 500, guests: 3, roundingKind: 'volume', unit: 'ml'), 380);
    });
  });

  group('whole rounding for units previously missing from allowlist', () {
    test('1 uovo × 1.5 → 2', () {
      expect(scaleAndRound(
          qtyBase4: 1, guests: 6, roundingKind: 'whole', unit: 'uovo'), 2);
    });

    test('3 vasetti × 0.5 → 2', () {
      expect(scaleAndRound(
          qtyBase4: 3, guests: 2, roundingKind: 'whole', unit: 'vasetto'), 2);
    });

    test('1 barattolo × 1.5 → 2', () {
      expect(scaleAndRound(
          qtyBase4: 1, guests: 6, roundingKind: 'whole', unit: 'barattolo'),
          2);
    });

    test('2 lattine × 1.5 → 3', () {
      expect(scaleAndRound(
          qtyBase4: 2, guests: 6, roundingKind: 'whole', unit: 'lattina'), 3);
    });

    test('1 confezione × 0.75 → 1', () {
      expect(scaleAndRound(
          qtyBase4: 1, guests: 3, roundingKind: 'whole', unit: 'confezione'),
          1);
    });

    test('1 mazzo × 1.25 → 2', () {
      expect(scaleAndRound(
          qtyBase4: 1, guests: 5, roundingKind: 'whole', unit: 'mazzo'), 2);
    });
  });
}
