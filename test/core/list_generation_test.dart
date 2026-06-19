import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/list_generation.dart';

ListLineInput line({
  required String id,
  String unit = 'g',
  bool isQb = false,
  double? qtyBase4,
  int guests = 4,
}) =>
    ListLineInput(
      ingredientId: id,
      unit: unit,
      isQb: isQb,
      qtyBase4: qtyBase4,
      guests: guests,
    );

void main() {
  group('aggregateList', () {
    test('a 4 commensali la quantità base 4 resta invariata', () {
      final rows = aggregateList([line(id: 'a', qtyBase4: 600, guests: 4)]);
      expect(rows.single.qty, 600);
      expect(rows.single.isQb, false);
    });

    test('riscala in base ai commensali (6 -> x1.5)', () {
      final rows = aggregateList([line(id: 'a', qtyBase4: 600, guests: 6)]);
      expect(rows.single.qty, 900);
    });

    test('aggrega lo stesso ingrediente da più piatti/giorni (FR-12)', () {
      final rows = aggregateList([
        line(id: 'a', qtyBase4: 600, guests: 4), // 600
        line(id: 'a', qtyBase4: 200, guests: 8), // 400
      ]);
      expect(rows.single.ingredientId, 'a');
      expect(rows.single.qty, 1000);
    });

    test('arrotonda una sola volta sul totale aggregato', () {
      // unità "pz" -> arrotonda per eccesso all'intero. 1.5 + 1.5 = 3.0
      final rows = aggregateList([
        line(id: 'p', unit: 'pz', qtyBase4: 1, guests: 6), // 1.5
        line(id: 'p', unit: 'pz', qtyBase4: 1, guests: 6), // 1.5
      ]);
      expect(rows.single.qty, 3);
    });

    test('i "quanto basta" compaiono una volta senza quantità', () {
      final rows = aggregateList([
        line(id: 'sale', isQb: true, guests: 4),
        line(id: 'sale', isQb: true, guests: 12),
      ]);
      expect(rows.single.isQb, true);
      expect(rows.single.qty, isNull);
    });

    test('lista vuota produce nessuna riga', () {
      expect(aggregateList([]), isEmpty);
    });
  });

  group('planHash', () {
    test('è indipendente dall\'ordine delle righe', () {
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

    test('cambia se cambiano i commensali', () {
      final a = planHash([line(id: 'a', qtyBase4: 100, guests: 4)]);
      final b = planHash([line(id: 'a', qtyBase4: 100, guests: 6)]);
      expect(a, isNot(b));
    });

    test('cambia se cambia la quantità base di un piatto', () {
      final a = planHash([line(id: 'a', qtyBase4: 100, guests: 4)]);
      final b = planHash([line(id: 'a', qtyBase4: 150, guests: 4)]);
      expect(a, isNot(b));
    });

    test('è deterministico e a 16 cifre esadecimali', () {
      final h = planHash([line(id: 'a', qtyBase4: 100, guests: 4)]);
      expect(h, planHash([line(id: 'a', qtyBase4: 100, guests: 4)]));
      expect(h, matches(RegExp(r'^[0-9a-f]{16}$')));
    });
  });
}
