/// Closed set of units of measure (FR-5).
///
/// The unit stored in `ingredient.unit` must be one of [Unit.dbValue].
/// This guarantees that aggregation in the shopping list never mixes
/// "g" with "gr" or "grammi" — they all map to the same enum member.
library;

enum Unit {
  grammi('g', 'Grammi (g)', 'weight'),
  chilogrammi('kg', 'Chilogrammi (kg)', 'weight'),
  millilitri('ml', 'Millilitri (ml)', 'volume'),
  litri('l', 'Litri (l)', 'volume'),
  pezzo('pz', 'Pezzo (pz)', 'whole');

  const Unit(this.dbValue, this.label, this.roundingKind);

  /// Canonical short form stored in the database.
  final String dbValue;

  /// Human-readable label for form selectors.
  final String label;

  /// Rounding kind derived from the unit, passed to [roundForUnit].
  final String roundingKind;

  /// Finds the enum member whose [dbValue] matches [value].
  /// Returns `null` if not recognized — use [tryParseLoose] for migration.
  static Unit? tryParse(String value) {
    for (final u in values) {
      if (u.dbValue == value) return u;
    }
    return null;
  }

  /// Loose parser that maps common aliases to the canonical enum member.
  /// Used during data migration of free-text units.
  static Unit? tryParseLoose(String value) {
    final v = value.toLowerCase().trim();
    return _aliases[v];
  }
}

const _aliases = <String, Unit>{
  // grammi
  'g': Unit.grammi,
  'gr': Unit.grammi,
  'grammi': Unit.grammi,
  'grammo': Unit.grammi,
  // chilogrammi
  'kg': Unit.chilogrammi,
  'chilogrammi': Unit.chilogrammi,
  'chilogrammo': Unit.chilogrammi,
  'kilo': Unit.chilogrammi,
  // millilitri
  'ml': Unit.millilitri,
  'millilitri': Unit.millilitri,
  'millilitro': Unit.millilitri,
  // litri
  'l': Unit.litri,
  'litri': Unit.litri,
  'litro': Unit.litri,
  'lt': Unit.litri,
  // pezzo
  'pz': Unit.pezzo,
  'pezzo': Unit.pezzo,
  'pezzi': Unit.pezzo,
  'pz.': Unit.pezzo,
  'unità': Unit.pezzo,
  'unita': Unit.pezzo,
};
