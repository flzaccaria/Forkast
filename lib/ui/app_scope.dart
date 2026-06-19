import 'package:flutter/widgets.dart';

import '../data/database.dart';

/// Makes the database (and the current household) available to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.database,
    required this.householdId,
    this.onHouseholdChanged,
    required super.child,
  });

  final AppDatabase database;
  final String householdId;

  /// Changes the device's active household (e.g. after pairing with another
  /// phone): the tree rebuilds with the new household's repositories.
  /// Null until the change is supported by the context.
  final ValueChanged<String>? onHouseholdChanged;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope non trovato nell\'albero dei widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      database != oldWidget.database || householdId != oldWidget.householdId;
}
