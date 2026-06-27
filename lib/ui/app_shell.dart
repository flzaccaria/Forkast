import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'dishes/dishes_screen.dart';
import 'plan/plan_screen.dart';
import 'list/list_screen.dart';
import 'settings/ingredients_screen.dart';
import 'settings/pairing_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.pairingCode});

  final String? pairingCode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 2; // default landing: Piano
  bool _pairingHandled = false;

  static const _screens = [
    IngredientsScreen(),
    DishesScreen(),
    PlanScreen(),
    ListScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_pairingHandled && widget.pairingCode != null) {
      _pairingHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PairingScreen(initialCode: widget.pairingCode),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            selectedIcon: const Icon(Icons.kitchen),
            label: l.navIngredients,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu),
            label: l.navDishes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: l.navPlan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: l.navList,
          ),
        ],
      ),
    );
  }
}
