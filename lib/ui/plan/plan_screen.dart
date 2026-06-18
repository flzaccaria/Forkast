import 'package:flutter/material.dart';

import '../widgets/settings_button.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano'),
        actions: const [SettingsButton()],
      ),
      body: const Center(child: Text('Piano')),
    );
  }
}
