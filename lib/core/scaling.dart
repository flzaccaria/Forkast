import 'package:flutter/foundation.dart';

double scaleQty({required double qtyBase4, required int guests}) {
  return qtyBase4 * (guests / 4);
}

const _smallWeightUnits = {'g', 'gr', 'grammi'};
const _smallVolumeUnits = {'ml', 'millilitri'};

double roundForUnit(double qty, String? roundingKind, String unit) {
  final u = unit.toLowerCase().trim();
  switch (roundingKind ?? 'weight') {
    case 'whole':
      return qty.ceilToDouble();
    case 'weight':
      if (_smallWeightUnits.contains(u)) return _ceilTo(qty, 10);
      return _ceilTo(qty, 0.1); // kg
    case 'volume':
      if (_smallVolumeUnits.contains(u)) return _ceilTo(qty, 10);
      return _ceilTo(qty, 0.1); // l, cl, dl
    default:
      assert(false, 'Unknown rounding_kind: $roundingKind');
      debugPrint('roundForUnit: unknown rounding_kind "$roundingKind" '
          'for unit "$unit" — falling back to ceil');
      return qty.ceilToDouble();
  }
}

double _ceilTo(double value, double step) {
  if (step >= 1) {
    return (value / step).ceilToDouble() * step;
  }
  // Fractional step: scale to integer space to avoid FP drift.
  final factor = (1 / step).round(); // 0.1 → 10
  return (value * factor).ceilToDouble() / factor;
}

double scaleAndRound({
  required double qtyBase4,
  required int guests,
  required String? roundingKind,
  required String unit,
}) {
  return roundForUnit(
      scaleQty(qtyBase4: qtyBase4, guests: guests), roundingKind, unit);
}
