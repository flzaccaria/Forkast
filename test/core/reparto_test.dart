import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/reparto.dart';

void main() {
  group('repartoSortIndex', () {
    test('follows the order of the route through the store', () {
      expect(repartoSortIndex('Ortofrutta'),
          lessThan(repartoSortIndex('Dispensa')));
      expect(repartoSortIndex('Dispensa'),
          lessThan(repartoSortIndex('Bevande')));
    });

    test('null and unknown departments end up at the bottom', () {
      final last = repartoSortIndex(reparti.last);
      expect(repartoSortIndex(null), greaterThan(last));
      expect(repartoSortIndex('Reparto inventato'), greaterThan(last));
      // null after any unknown, for stability.
      expect(repartoSortIndex(null),
          greaterThan(repartoSortIndex('Reparto inventato')));
    });

    test('sorting a mixed list groups by department', () {
      final items = ['Bevande', null, 'Ortofrutta', 'Dispensa'];
      items.sort((a, b) =>
          repartoSortIndex(a).compareTo(repartoSortIndex(b)));
      expect(items, ['Ortofrutta', 'Dispensa', 'Bevande', null]);
    });
  });
}
