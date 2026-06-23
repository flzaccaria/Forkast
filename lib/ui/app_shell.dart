import 'package:flutter/material.dart';

import 'dishes/dishes_screen.dart';
import 'plan/plan_screen.dart';
import 'list/list_screen.dart';
import 'settings/ingredients_screen.dart';
import 'settings/pairing_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.pairingCode});

  /// When non-null the pairing screen opens automatically with this code
  /// pre-filled (e.g. from a `?code=` query parameter in the PWA URL).
  final String? pairingCode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _pairingHandled = false;

  static const _screens = [
    DishesScreen(),
    PlanScreen(),
    ListScreen(),
    IngredientsScreen(),
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Piatti',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Piano',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Lista',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Ingredienti',
          ),
        ],
      ),
    );
  }
}
