import 'package:flutter/material.dart';

import '../widgets/settings_button.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista'),
        actions: const [SettingsButton()],
      ),
      body: const Center(child: Text('Lista')),
    );
  }
}
