import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/list_generation.dart';

ListLineInput line({
  required String id,
  String unit = 'g',
  String roundingKind = 'weight',
  bool isQb = false,
  double? qtyBase4,
  int guests = 4,
}) =>
    ListLineInput(
      ingredientId: id,
      unit: unit,
      roundingKind: roundingKind,
      isQb: isQb,
      qtyBase4: qtyBase4,
      guests: guests,
    );

void main() {
  group('aggregateList', () {
    test('at 4 guests the base-4 quantity stays unchanged', () {
      final rows = aggregateList([line(id: 'a', qtyBase4: 600, guests: 4)]);
      expect(rows.single.qty, 600);
      expect(rows.single.isQb, false);
    });

    test('rescales based on guests (6 -> x1.5)', () {
      final rows = aggregateList([line(id: 'a', qtyBase4: 600, guests: 6)]);
      expect(rows.single.qty, 900);
    });

    test('aggregates the same ingredient across multiple dishes/days (FR-12)', () {
      final rows = aggregateList([
        line(id: 'a', qtyBase4: 600, guests: 4), // 600
        line(id: 'a', qtyBase4: 200, guests: 8), // 400
      ]);
      expect(rows.single.ingredientId, 'a');
      expect(rows.single.qty, 1000);
    });

    test('rounds only once on the aggregated total', () {
      final rows = aggregateList([
        line(id: 'p', unit: 'pz', roundingKind: 'whole', qtyBase4: 1, guests: 6),
        line(id: 'p', unit: 'pz', roundingKind: 'whole', qtyBase4: 1, guests: 6),
      ]);
      expect(rows.single.qty, 3);
    });

    test('"to taste" items appear once without a quantity', () {
      final rows = aggregateList([
        line(id: 'sale', isQb: true, guests: 4),
        line(id: 'sale', isQb: true, guests: 12),
      ]);
      expect(rows.single.isQb, true);
      expect(rows.single.qty, isNull);
    });

    test('empty list produces no rows', () {
      expect(aggregateList([]), isEmpty);
    });

    test('whole rounding applies via roundingKind, not unit string', () {
      final rows = aggregateList([
        line(id: 'uovo', unit: 'uovo', roundingKind: 'whole', qtyBase4: 1, guests: 6),
      ]);
      expect(rows.single.qty, 2);
    });

    test('asserts on unit mismatch for the same ingredient (§6 ADR best-effort)', () {
      expect(
        () => aggregateList([
          line(id: 'x', unit: 'g', qtyBase4: 100, guests: 4),
          line(id: 'x', unit: 'ml', qtyBase4: 200, guests: 4),
        ]),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('planHash', () {
    test('is independent of the order of the rows', () {
      final a = planHash([
        line(id: 'a', qtyBase4: 100, guests: 4),
        line(id: 'b', qtyBase4: 200, guests: 6),
      ]);
      final b = planHash([
        line(id: 'b', qtyBase4: 200, guests: 6),
        line(id: 'a', qtyBase4: 100, guests: 4),
      ]);
      expect(a, b);
    });

    test('changes if the guests change', () {
      final a = planHash([line(id: 'a', qtyBase4: 100, guests: 4)]);
      final b = planHash([line(id: 'a', qtyBase4: 100, guests: 6)]);
      expect(a, isNot(b));
    });

    test('changes if the base quantity of a dish changes', () {
      final a = planHash([line(id: 'a', qtyBase4: 100, guests: 4)]);
      final b = planHash([line(id: 'a', qtyBase4: 150, guests: 4)]);
      expect(a, isNot(b));
    });

    test('changes if the roundingKind changes (FR-21)', () {
      final a = planHash([
        line(id: 'a', qtyBase4: 100, guests: 4, roundingKind: 'weight'),
      ]);
      final b = planHash([
        line(id: 'a', qtyBase4: 100, guests: 4, roundingKind: 'whole'),
      ]);
      expect(a, isNot(b));
    });

    test('is deterministic and 16 hexadecimal digits', () {
      final h = planHash([line(id: 'a', qtyBase4: 100, guests: 4)]);
      expect(h, planHash([line(id: 'a', qtyBase4: 100, guests: 4)]));
      expect(h, matches(RegExp(r'^[0-9a-f]{16}$')));
    });
  });
}
