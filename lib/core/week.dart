// ISO-8601 week calculation, pure and testable module.

/// ISO-8601 week number (1..53) of the date.
int isoWeekNumber(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final firstDayOfYear = DateTime.utc(thursday.year, 1, 1);
  final diff = thursday.difference(firstDayOfYear).inDays;
  return (diff / 7).floor() + 1;
}

/// ISO-8601 year of the date (may differ from the calendar year around the
/// December/January boundary).
int isoWeekYear(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  return thursday.year;
}

/// Date of the day `weekday` (1=Mon..7=Sun) in the ISO week (year, week).
DateTime dateOfIsoWeek(int year, int week, int weekday) {
  // January 4 always falls in ISO week 1.
  final jan4 = DateTime.utc(year, 1, 4);
  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  final result = mondayOfWeek1.add(Duration(days: (week - 1) * 7 + (weekday - 1)));
  // UTC arithmetic to avoid daylight-saving offsets, but returns a local
  // date (midnight) consistent with usage in the UI.
  return DateTime(result.year, result.month, result.day);
}

/// The 7 days of the week (`weekday` values 1..7) ordered according to the
/// week start day. `weekStartDay` follows the `DateTime.weekday` convention:
/// 1 = Monday (default), 7 = Sunday. Out-of-range values fall back to Monday.
List<int> orderedWeekdays(int weekStartDay) {
  final start = (weekStartDay >= 1 && weekStartDay <= 7) ? weekStartDay : 1;
  return List.generate(7, (i) => ((start - 1 + i) % 7) + 1);
}
