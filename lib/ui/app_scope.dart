import 'package:flutter/widgets.dart';

import '../data/database.dart';

/// Rende il database (e l'household corrente) disponibili all'albero dei widget.
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

  /// Cambia l'household attivo del dispositivo (es. dopo l'abbinamento a un
  /// altro telefono): l'albero si ricostruisce con i repository del nuovo
  /// household. Null finché il cambio non è supportato dal contesto.
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
