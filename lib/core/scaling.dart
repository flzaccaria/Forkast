const _wholeUnits = {'pz', 'pezzo', 'pezzi', 'fetta', 'fette', 'spicchio', 'spicchi'};

double scaleQty({required double qtyBase4, required int guests}) {
  return qtyBase4 * (guests / 4);
}

double roundForUnit(double qty, String unit) {
  final u = unit.toLowerCase().trim();
  if (_wholeUnits.contains(u)) {
    return qty.ceilToDouble();
  }
  return (qty * 2).ceilToDouble() / 2;
}

double scaleAndRound({
  required double qtyBase4,
  required int guests,
  required String unit,
}) {
  return roundForUnit(scaleQty(qtyBase4: qtyBase4, guests: guests), unit);
}
