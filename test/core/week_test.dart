import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/week.dart';

void main() {
  group('isoWeekNumber / isoWeekYear', () {
    test('1 gennaio 2026 (giovedì) è la settimana 1 del 2026', () {
      final d = DateTime(2026, 1, 1);
      expect(isoWeekNumber(d), 1);
      expect(isoWeekYear(d), 2026);
    });

    test('1 gennaio 2021 (venerdì) appartiene alla settimana 53 del 2020', () {
      final d = DateTime(2021, 1, 1);
      expect(isoWeekNumber(d), 53);
      expect(isoWeekYear(d), 2020);
    });

    test('1 gennaio 2023 (domenica) appartiene alla settimana 52 del 2022', () {
      final d = DateTime(2023, 1, 1);
      expect(isoWeekNumber(d), 52);
      expect(isoWeekYear(d), 2022);
    });

    test('30 dicembre 2024 (lunedì) è la settimana 1 del 2025', () {
      final d = DateTime(2024, 12, 30);
      expect(isoWeekNumber(d), 1);
      expect(isoWeekYear(d), 2025);
    });
  });

  group('dateOfIsoWeek', () {
    test('giovedì della settimana 1 del 2026 è il 1 gennaio 2026', () {
      expect(dateOfIsoWeek(2026, 1, DateTime.thursday), DateTime(2026, 1, 1));
    });

    test('lunedì della settimana 1 del 2025 è il 30 dicembre 2024', () {
      expect(dateOfIsoWeek(2025, 1, DateTime.monday), DateTime(2024, 12, 30));
    });

    test('roundtrip: ricostruisce la data da (anno, settimana, weekday)', () {
      for (final d in [
        DateTime(2026, 6, 19),
        DateTime(2020, 2, 29),
        DateTime(2023, 12, 31),
        DateTime(2024, 1, 1),
      ]) {
        final restored =
            dateOfIsoWeek(isoWeekYear(d), isoWeekNumber(d), d.weekday);
        expect(restored, DateTime(d.year, d.month, d.day),
            reason: 'roundtrip fallito per $d');
      }
    });
  });

  group('orderedWeekdays', () {
    test('inizio lunedì', () {
      expect(orderedWeekdays(DateTime.monday), [1, 2, 3, 4, 5, 6, 7]);
    });

    test('inizio domenica', () {
      expect(orderedWeekdays(DateTime.sunday), [7, 1, 2, 3, 4, 5, 6]);
    });

    test('valore fuori range ricade su lunedì', () {
      expect(orderedWeekdays(0), [1, 2, 3, 4, 5, 6, 7]);
      expect(orderedWeekdays(9), [1, 2, 3, 4, 5, 6, 7]);
    });
  });
}
