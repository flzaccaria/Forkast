import '../l10n/generated/app_localizations.dart';

String formatLastPlanned(DateTime? lastPlannedDate, AppLocalizations l) {
  if (lastPlannedDate == null) return l.dishNeverPlanned;
  final now = DateTime.now();
  final diff = now.difference(lastPlannedDate);
  if (diff.isNegative) return l.dishNeverPlanned;
  final weeks = diff.inDays ~/ 7;
  if (weeks == 0) return l.dishThisWeek;
  if (weeks == 1) return l.dishOneWeekAgo;
  return l.dishWeeksAgo(weeks);
}

int weeksAgo(DateTime? lastPlannedDate) {
  if (lastPlannedDate == null) return -1;
  final diff = DateTime.now().difference(lastPlannedDate);
  if (diff.isNegative) return -1;
  return diff.inDays ~/ 7;
}
