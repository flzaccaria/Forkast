import 'package:flutter/material.dart';

import 'dishes/dishes_screen.dart';
import 'plan/plan_screen.dart';
import 'list/list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    DishesScreen(),
    PlanScreen(),
    ListScreen(),
  ];

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
            icon: Icon(Icons.restaurant_menu),
            label: 'Piatti',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Piano',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Lista',
          ),
        ],
      ),
    );
  }
}
