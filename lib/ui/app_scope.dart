import 'package:flutter/widgets.dart';

import '../data/database.dart';

/// Rende il database (e l'household corrente) disponibili all'albero dei widget.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.database,
    required this.householdId,
    required super.child,
  });

  final AppDatabase database;
  final String householdId;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope non trovato nell\'albero dei widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      database != oldWidget.database || householdId != oldWidget.householdId;
}
