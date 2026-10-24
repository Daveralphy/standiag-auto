import 'package:flutter/material.dart';

import 'app/foundation/onboarding_screen.dart';
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
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: startupError == null
          ? const OnboardingScreen()
          : _StartupIssueScreen(
              isConfigurationIssue: startupError is StateError,
            ),
    );
  }
}

class _StartupIssueScreen extends StatelessWidget {
  const _StartupIssueScreen({required this.isConfigurationIssue});

  final bool isConfigurationIssue;

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
                    isConfigurationIssue
                        ? Icons.settings_suggest_outlined
                        : Icons.cloud_off_outlined,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isConfigurationIssue
                        ? 'Complete app setup'
                        : 'Unable to start Standiag Auto',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isConfigurationIssue
                        ? 'Standiag Auto needs Firebase client configuration '
                            'before sign-in can run. This is a setup issue, '
                            'not an account error.'
                        : 'The app could not initialize its required service. '
                            'Check your connection and Firebase platform '
                            'configuration, then try again.',
                  ),
                  if (isConfigurationIssue) ...[
                    const SizedBox(height: 20),
                    SelectableText(
                      'Supply the Firebase client values using --dart-define. '
                      'See README.md for the required platform-specific values.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Use client app configuration from Firebase Console. '
                      'Never use a service-account key in the app.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
