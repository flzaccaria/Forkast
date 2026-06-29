import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/surprise_me.dart';

void main() {
  SurpriseMeCandidate candidate(String id,
      {DateTime? lastPlanned, String? difficulty, String? timeEstimate}) {
    return SurpriseMeCandidate(
      dishId: id,
      lastPlannedDate: lastPlanned,
      difficulty: difficulty,
      timeEstimate: timeEstimate,
    );
  }

  test('fills all empty days', () {
    final result = selectSurpriseDishes(
      emptyDays: [1, 2, 3],
      alreadyAssignedThisWeek: {},
      candidates: [candidate('a'), candidate('b'), candidate('c')],
    );
    expect(result.filledCount, 3);
    expect(result.requestedCount, 3);
    expect(result.isPartial, false);
    expect(result.assignments.keys, containsAll([1, 2, 3]));
  });

  test('no repeats within the week', () {
    final result = selectSurpriseDishes(
      emptyDays: [1, 2, 3],
      alreadyAssignedThisWeek: {},
      candidates: [candidate('a'), candidate('b'), candidate('c')],
    );
    final ids = result.assignments.values.toSet();
    expect(ids.length, 3);
  });

  test('prefers least recently planned', () {
    final oldDate = DateTime(2026, 1, 1);
    final recentDate = DateTime(2026, 6, 1);
    final result = selectSurpriseDishes(
      emptyDays: [1],
      alreadyAssignedThisWeek: {},
      candidates: [
        candidate('recent', lastPlanned: recentDate),
        candidate('old', lastPlanned: oldDate),
        candidate('never'),
      ],
    );
    expect(result.assignments[1], 'never');
  });

  test('partial fill when not enough candidates', () {
    final result = selectSurpriseDishes(
      emptyDays: [1, 2, 3],
      alreadyAssignedThisWeek: {},
      candidates: [candidate('a')],
    );
    expect(result.filledCount, 1);
    expect(result.requestedCount, 3);
    expect(result.isPartial, true);
  });

  test('excludes already assigned dishes', () {
    final result = selectSurpriseDishes(
      emptyDays: [1],
      alreadyAssignedThisWeek: {'a'},
      candidates: [candidate('a'), candidate('b')],
    );
    expect(result.assignments[1], 'b');
  });

  test('applies weekday difficulty filter', () {
    final result = selectSurpriseDishes(
      emptyDays: [DateTime.monday],
      alreadyAssignedThisWeek: {},
      candidates: [
        candidate('hard', difficulty: 'difficile'),
        candidate('easy', difficulty: 'facile'),
      ],
      weekdayDifficulty: 'facile',
    );
    expect(result.assignments[DateTime.monday], 'easy');
  });

  test('falls back to all candidates when no match for filter', () {
    final result = selectSurpriseDishes(
      emptyDays: [DateTime.monday],
      alreadyAssignedThisWeek: {},
      candidates: [candidate('hard', difficulty: 'difficile')],
      weekdayDifficulty: 'facile',
    );
    expect(result.assignments[DateTime.monday], 'hard');
  });

  test('empty input returns empty result', () {
    final result = selectSurpriseDishes(
      emptyDays: [],
      alreadyAssignedThisWeek: {},
      candidates: [candidate('a')],
    );
    expect(result.filledCount, 0);
    expect(result.requestedCount, 0);
    expect(result.isPartial, false);
  });
}
