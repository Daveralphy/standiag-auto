import 'package:flutter/material.dart';

import 'app/foundation/entry_screen.dart';
import 'app/theme/app_theme.dart';

/// Fresh application root. Legacy routing, theme state and screen providers
/// are intentionally not wired into the new application.
class StanDiagApp extends StatelessWidget {
  const StanDiagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Standiag Auto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const EntryScreen(),
    );
  }
}
