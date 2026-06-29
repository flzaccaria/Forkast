import 'package:flutter_test/flutter_test.dart';
import 'package:forkast/core/last_planned.dart';

void main() {
  test('weeksAgo returns -1 for null', () {
    expect(weeksAgo(null), -1);
  });

  test('weeksAgo returns 0 for today', () {
    expect(weeksAgo(DateTime.now()), 0);
  });

  test('weeksAgo returns correct number for past dates', () {
    final threeWeeksAgo = DateTime.now().subtract(const Duration(days: 21));
    expect(weeksAgo(threeWeeksAgo), 3);
  });

  test('weeksAgo returns -1 for future dates', () {
    final future = DateTime.now().add(const Duration(days: 7));
    expect(weeksAgo(future), -1);
  });
}
