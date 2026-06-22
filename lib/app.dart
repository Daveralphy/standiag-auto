// Root application widget for StanDiag Auto.
// Wires together the theme, router, and font configuration.
// This is the only place MaterialApp.router is constructed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

class StanDiagApp extends ConsumerWidget {
  const StanDiagApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider — it automatically redirects on auth state changes
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'StanDiag Auto',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
    );
  }
}