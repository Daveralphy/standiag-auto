import 'package:flutter/material.dart';

import 'app/foundation/entry_screen.dart';
import 'app/theme/app_theme.dart';

/// Fresh application root. Legacy routing, theme state and screen providers
/// are intentionally not wired into the new application.
class StanDiagApp extends StatelessWidget {
  const StanDiagApp({super.key, this.startupError});

  /// A non-null value means Firebase could not be initialized. Keep the app
  /// launchable so setup problems are explained instead of crashing at start.
  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Standiag Auto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: startupError == null
          ? const EntryScreen()
          : const _FirebaseSetupScreen(),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings_suggest_outlined,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'One setup step left',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Standiag Auto needs its Firebase client configuration '
                    'before sign-in can run. This is a setup issue, not an '
                    'account error.',
                  ),
                  const SizedBox(height: 20),
                  SelectableText(
                    'Run with --dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_WEB_API_KEY',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use the Web API key from Firebase Console → Project '
                    'settings → General. Never use a service-account key here.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
