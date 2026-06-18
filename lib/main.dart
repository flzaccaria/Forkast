import 'package:flutter/material.dart';

import 'ui/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: inizializzare Supabase, PowerSync e drift DB
  runApp(const ForkastApp());
}

class ForkastApp extends StatelessWidget {
  const ForkastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forkast',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
