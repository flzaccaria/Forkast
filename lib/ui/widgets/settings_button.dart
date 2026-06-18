import 'package:flutter/material.dart';

import '../settings/settings_screen.dart';

/// Pulsante Impostazioni condiviso dalle AppBar delle tre sezioni.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Impostazioni',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    );
  }
}
