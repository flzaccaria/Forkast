class SurpriseMeCandidate {
  SurpriseMeCandidate({
    required this.dishId,
    this.difficulty,
    this.timeEstimate,
    this.lastPlannedDate,
  });

  final String dishId;
  final String? difficulty;
  final String? timeEstimate;
  final DateTime? lastPlannedDate;
}

class SurpriseMeResult {
  SurpriseMeResult({
    required this.assignments,
    required this.requestedCount,
    required this.filledCount,
  });

  final Map<int, String> assignments;
  final int requestedCount;
  final int filledCount;
  bool get isPartial => filledCount < requestedCount;
}

SurpriseMeResult selectSurpriseDishes({
  required List<int> emptyDays,
  required Set<String> alreadyAssignedThisWeek,
  required List<SurpriseMeCandidate> candidates,
  String? weekdayDifficulty,
  String? weekdayTimeEstimate,
}) {
  final assignments = <int, String>{};
  final used = Set<String>.of(alreadyAssignedThisWeek);

  for (final day in emptyDays) {
    final isWeekday = day >= DateTime.monday && day <= DateTime.friday;

    var pool = candidates.where((c) => !used.contains(c.dishId)).toList();

    if (isWeekday) {
      if (weekdayDifficulty != null) {
        final filtered =
            pool.where((c) => c.difficulty == weekdayDifficulty).toList();
        if (filtered.isNotEmpty) pool = filtered;
      }
      if (weekdayTimeEstimate != null) {
        final filtered =
            pool.where((c) => c.timeEstimate == weekdayTimeEstimate).toList();
        if (filtered.isNotEmpty) pool = filtered;
      }
    }

    pool.sort((a, b) {
      final aMs = a.lastPlannedDate?.millisecondsSinceEpoch ?? 0;
      final bMs = b.lastPlannedDate?.millisecondsSinceEpoch ?? 0;
      if (aMs != bMs) return aMs.compareTo(bMs);
      return a.dishId.compareTo(b.dishId);
    });

    if (pool.isEmpty) continue;
    final pick = pool.first;
    assignments[day] = pick.dishId;
    used.add(pick.dishId);
  }

  return SurpriseMeResult(
    assignments: assignments,
    requestedCount: emptyDays.length,
    filledCount: assignments.length,
  );
}
