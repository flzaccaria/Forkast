import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/reparto.dart';

void main() {
  group('repartoSortIndex', () {
    test('segue l\'ordine del percorso in negozio', () {
      expect(repartoSortIndex('Ortofrutta'),
          lessThan(repartoSortIndex('Dispensa')));
      expect(repartoSortIndex('Dispensa'),
          lessThan(repartoSortIndex('Bevande')));
    });

    test('null e reparti sconosciuti finiscono in fondo', () {
      final last = repartoSortIndex(reparti.last);
      expect(repartoSortIndex(null), greaterThan(last));
      expect(repartoSortIndex('Reparto inventato'), greaterThan(last));
      // null dopo qualunque sconosciuto, per stabilità.
      expect(repartoSortIndex(null),
          greaterThan(repartoSortIndex('Reparto inventato')));
    });

    test('ordinare una lista mista raggruppa per reparto', () {
      final items = ['Bevande', null, 'Ortofrutta', 'Dispensa'];
      items.sort((a, b) =>
          repartoSortIndex(a).compareTo(repartoSortIndex(b)));
      expect(items, ['Ortofrutta', 'Dispensa', 'Bevande', null]);
    });
  });
}
