import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/qty_format.dart';

void main() {
  group('formatQty', () {
    test('integers have no decimals', () {
      expect(formatQty(4), '4');
      expect(formatQty(900), '900');
    });

    test('uses comma as decimal separator (it_IT)', () {
      expect(formatQty(1.5), '1,5');
      expect(formatQty(499.5), '499,5');
      expect(formatQty(0.75), '0,75');
    });

    test('no trailing zeros', () {
      expect(formatQty(2.0), '2');
      expect(formatQty(3.10), '3,1');
    });

    test('thousands use dot separator (it_IT)', () {
      expect(formatQty(1000), '1.000');
      expect(formatQty(1500.5), '1.500,5');
    });
  });
}
