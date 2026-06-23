/// Structured single-choice fields on a dish (FR-14 v0.6).
///
/// Replace the free-form "attributo" tags. Both are optional, ordered scales.
library;

enum Difficulty {
  facile('facile', 'Facile'),
  medio('medio', 'Medio'),
  difficile('difficile', 'Difficile');

  const Difficulty(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static Difficulty? tryParse(String? value) {
    if (value == null) return null;
    for (final d in values) {
      if (d.dbValue == value) return d;
    }
    return null;
  }
}

enum TimeEstimate {
  veloce('veloce', 'Veloce'),
  medio('medio', 'Medio'),
  lento('lento', 'Lento');

  const TimeEstimate(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static TimeEstimate? tryParse(String? value) {
    if (value == null) return null;
    for (final t in values) {
      if (t.dbValue == value) return t;
    }
    return null;
  }
}
