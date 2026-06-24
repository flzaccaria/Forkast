import 'package:intl/intl.dart';

final _fmtCache = <String, (NumberFormat, NumberFormat)>{};

(NumberFormat, NumberFormat) _fmts(String locale) =>
    _fmtCache.putIfAbsent(locale, () => (
          NumberFormat('#,##0', locale),
          NumberFormat('#,##0.##', locale),
        ));

/// Formats a quantity for display using the given locale.
/// No trailing zeros; decimal separator follows the locale
/// (comma for it/da, dot for en).
String formatQty(double qty, {String locale = 'it_IT'}) {
  final (intFmt, decFmt) = _fmts(locale);
  if (qty == qty.roundToDouble()) {
    return intFmt.format(qty.toInt());
  }
  return decFmt.format(qty);
}
