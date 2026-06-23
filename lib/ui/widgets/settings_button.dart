import 'package:flutter/material.dart';

import '../settings/settings_screen.dart';

/// Settings button shared by the AppBars of the three sections.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Impostazioni',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    );
  }
}
