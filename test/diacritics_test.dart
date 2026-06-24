import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/diacritics.dart';

void main() {
  group('removeDiacritics', () {
    test('strips Italian accented vowels', () {
      expect(removeDiacritics('Caffè'), 'Caffe');
      expect(removeDiacritics('perché'), 'perche');
      expect(removeDiacritics('più'), 'piu');
      expect(removeDiacritics('àèéìòù'), 'aeeiou');
    });

    test('strips uppercase accented vowels', () {
      expect(removeDiacritics('ÀÈÉÌÒÙ'), 'AEEIOU');
    });

    test('maps Danish æ/ø/å', () {
      expect(removeDiacritics('æble'), 'aeble');
      expect(removeDiacritics('ørred'), 'oerred');
      expect(removeDiacritics('blåbær'), 'blaabaer');
      // uppercase
      expect(removeDiacritics('Ærter'), 'Aerter');
      expect(removeDiacritics('Ål'), 'Aal');
      expect(removeDiacritics('Ø'), 'Oe');
    });

    test('passes through plain ASCII unchanged', () {
      expect(removeDiacritics('Pomodori freschi'), 'Pomodori freschi');
      expect(removeDiacritics('abc123'), 'abc123');
    });

    test('handles empty string', () {
      expect(removeDiacritics(''), '');
    });
  });

  group('accent-insensitive search simulation', () {
    bool matches(String haystack, String needle) {
      final h = removeDiacritics(haystack).toLowerCase();
      final n = removeDiacritics(needle).toLowerCase();
      return h.contains(n);
    }

    test('"caffe" matches "Caffè"', () {
      expect(matches('Caffè', 'caffe'), isTrue);
    });

    test('"cafe" does not match "Caffè" (different letter count)', () {
      expect(matches('Caffè', 'cafe'), isFalse);
    });

    test('"pomod" matches "Pomodori"', () {
      expect(matches('Pomodori', 'pomod'), isTrue);
    });

    test('"CAFFE" matches "caffè" (case-insensitive)', () {
      expect(matches('caffè', 'CAFFE'), isTrue);
    });

    test('"aer" matches "Ærter" via Danish ae mapping', () {
      expect(matches('Ærter', 'aer'), isTrue);
    });

    test('no false positive on unrelated strings', () {
      expect(matches('Basilico', 'pomod'), isFalse);
    });
  });
}
