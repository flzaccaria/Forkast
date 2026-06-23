import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/unit.dart';

void main() {
  group('Unit.tryParse', () {
    test('parses canonical dbValue', () {
      expect(Unit.tryParse('g'), Unit.grammi);
      expect(Unit.tryParse('kg'), Unit.chilogrammi);
      expect(Unit.tryParse('ml'), Unit.millilitri);
      expect(Unit.tryParse('l'), Unit.litri);
      expect(Unit.tryParse('pz'), Unit.pezzo);
    });

    test('returns null for unknown values', () {
      expect(Unit.tryParse('gr'), isNull);
      expect(Unit.tryParse('grammi'), isNull);
      expect(Unit.tryParse(''), isNull);
    });
  });

  group('Unit.tryParseLoose', () {
    test('maps common aliases for grammi', () {
      expect(Unit.tryParseLoose('g'), Unit.grammi);
      expect(Unit.tryParseLoose('gr'), Unit.grammi);
      expect(Unit.tryParseLoose('grammi'), Unit.grammi);
      expect(Unit.tryParseLoose('grammo'), Unit.grammi);
      expect(Unit.tryParseLoose('GR'), Unit.grammi);
    });

    test('maps common aliases for chilogrammi', () {
      expect(Unit.tryParseLoose('kg'), Unit.chilogrammi);
      expect(Unit.tryParseLoose('chilogrammi'), Unit.chilogrammi);
      expect(Unit.tryParseLoose('kilo'), Unit.chilogrammi);
    });

    test('maps common aliases for millilitri', () {
      expect(Unit.tryParseLoose('ml'), Unit.millilitri);
      expect(Unit.tryParseLoose('millilitri'), Unit.millilitri);
    });

    test('maps common aliases for litri', () {
      expect(Unit.tryParseLoose('l'), Unit.litri);
      expect(Unit.tryParseLoose('litri'), Unit.litri);
      expect(Unit.tryParseLoose('lt'), Unit.litri);
    });

    test('maps common aliases for pezzo', () {
      expect(Unit.tryParseLoose('pz'), Unit.pezzo);
      expect(Unit.tryParseLoose('pezzo'), Unit.pezzo);
      expect(Unit.tryParseLoose('pezzi'), Unit.pezzo);
      expect(Unit.tryParseLoose('pz.'), Unit.pezzo);
    });

    test('returns null for completely unknown values', () {
      expect(Unit.tryParseLoose('foo'), isNull);
      expect(Unit.tryParseLoose(''), isNull);
    });

    test('is case-insensitive and trims whitespace', () {
      expect(Unit.tryParseLoose(' G '), Unit.grammi);
      expect(Unit.tryParseLoose('ML'), Unit.millilitri);
    });
  });

  test('every Unit has a distinct dbValue', () {
    final dbValues = Unit.values.map((u) => u.dbValue).toSet();
    expect(dbValues.length, Unit.values.length);
  });

  test('every Unit has a non-empty roundingKind', () {
    for (final u in Unit.values) {
      expect(u.roundingKind, isNotEmpty);
    }
  });
}
