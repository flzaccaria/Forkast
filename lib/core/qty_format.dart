import 'package:intl/intl.dart';

final _intFmt = NumberFormat('#,##0', 'it_IT');
final _decFmt = NumberFormat('#,##0.##', 'it_IT');

/// Formats a quantity for display: no trailing zeros, Italian decimal
/// separator (virgola). Integers are shown without decimals.
String formatQty(double qty) {
  if (qty == qty.roundToDouble()) {
    return _intFmt.format(qty.toInt());
  }
  return _decFmt.format(qty);
}
