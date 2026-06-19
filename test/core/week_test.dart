import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/week.dart';

void main() {
  group('isoWeekNumber / isoWeekYear', () {
    test('January 1, 2026 (Thursday) is week 1 of 2026', () {
      final d = DateTime(2026, 1, 1);
      expect(isoWeekNumber(d), 1);
      expect(isoWeekYear(d), 2026);
    });

    test('January 1, 2021 (Friday) belongs to week 53 of 2020', () {
      final d = DateTime(2021, 1, 1);
      expect(isoWeekNumber(d), 53);
      expect(isoWeekYear(d), 2020);
    });

    test('January 1, 2023 (Sunday) belongs to week 52 of 2022', () {
      final d = DateTime(2023, 1, 1);
      expect(isoWeekNumber(d), 52);
      expect(isoWeekYear(d), 2022);
    });

    test('December 30, 2024 (Monday) is week 1 of 2025', () {
      final d = DateTime(2024, 12, 30);
      expect(isoWeekNumber(d), 1);
      expect(isoWeekYear(d), 2025);
    });
  });

  group('dateOfIsoWeek', () {
    test('Thursday of week 1 of 2026 is January 1, 2026', () {
      expect(dateOfIsoWeek(2026, 1, DateTime.thursday), DateTime(2026, 1, 1));
    });

    test('Monday of week 1 of 2025 is December 30, 2024', () {
      expect(dateOfIsoWeek(2025, 1, DateTime.monday), DateTime(2024, 12, 30));
    });

    test('roundtrip: reconstructs the date from (year, week, weekday)', () {
      for (final d in [
        DateTime(2026, 6, 19),
        DateTime(2020, 2, 29),
        DateTime(2023, 12, 31),
        DateTime(2024, 1, 1),
      ]) {
        final restored =
            dateOfIsoWeek(isoWeekYear(d), isoWeekNumber(d), d.weekday);
        expect(restored, DateTime(d.year, d.month, d.day),
            reason: 'roundtrip failed for $d');
      }
    });
  });

  group('orderedWeekdays', () {
    test('start Monday', () {
      expect(orderedWeekdays(DateTime.monday), [1, 2, 3, 4, 5, 6, 7]);
    });

    test('start Sunday', () {
      expect(orderedWeekdays(DateTime.sunday), [7, 1, 2, 3, 4, 5, 6]);
    });

    test('out-of-range value falls back to Monday', () {
      expect(orderedWeekdays(0), [1, 2, 3, 4, 5, 6, 7]);
      expect(orderedWeekdays(9), [1, 2, 3, 4, 5, 6, 7]);
    });
  });
}
