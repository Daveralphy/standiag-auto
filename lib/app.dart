// Root application widget for StanDiag Auto.
// Wires together the theme, router, and font configuration.
// This is the only place MaterialApp.router is constructed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'shared/widget/offline_banner.dart';
import 'shared/widget/system_ui_style.dart';

class StanDiagApp extends ConsumerWidget {
  const StanDiagApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider — it automatically redirects on auth state changes
    final router = ref.watch(routerProvider);

    // Single source of truth for the whole app's theme: settingsProvider.
    // Both AppColors (read by every screen via its static getters) and
    // SystemUiStyle (the phone's status bar) are kept in sync with it here,
    // synchronously, before any descendant widget below builds this frame.
    final isLight = ref.watch(settingsProvider.select((s) => s.theme == 'Light'));
    final brightness = isLight ? Brightness.light : Brightness.dark;
    AppColors.setBrightness(brightness);
    SystemUiStyle.setBrightness(brightness);
    SystemUiStyle.apply();

    return MaterialApp.router(
      title: 'StanDiag Auto',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      // Mounted once here so every routed screen gets the offline banner
      // automatically, instead of each screen wiring its own connectivity check.
      //
      // AppColors.xxx are plain static getters, not something Flutter's
      // rebuild system can subscribe to — a screen that isn't otherwise
      // rebuilding for an unrelated reason (its own Riverpod watch, a
      // setState) never re-reads them just because the theme flipped, which
      // is exactly the "some areas stayed on the old theme" bug. `child` here
      // is go_router's live Navigator output, so giving this wrapper a
      // changing Key (an earlier attempt) tears down and recreates the whole
      // Navigator — which go_router doesn't expect and crashes on, especially
      // when the toggle triggering it lives on the very screen being torn
      // down. _ThemeRebuildScope instead walks the *existing* element tree
      // and marks it dirty in place, so every mounted screen re-runs build()
      // without anything being disposed or remounted.
      builder: (context, child) => Stack(
        children: [
          if (child != null) _ThemeRebuildScope(isLight: isLight, child: child),
          const OfflineBanner(),
        ],
      ),
    );
  }
}

/// Forces every element already mounted below it to re-run build() when
/// [isLight] flips, without disposing or remounting any of them — safe for
/// go_router's Navigator and whatever screen is currently active (including
/// one that triggered this very change from inside its own event handler).
class _ThemeRebuildScope extends StatefulWidget {
  final bool isLight;
  final Widget child;

  const _ThemeRebuildScope({required this.isLight, required this.child});

  @override
  State<_ThemeRebuildScope> createState() => _ThemeRebuildScopeState();
}

class _ThemeRebuildScopeState extends State<_ThemeRebuildScope> {
  @override
  void didUpdateWidget(_ThemeRebuildScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLight != widget.isLight) {
      // Deferred to the next frame — didUpdateWidget runs mid-build, and
      // this element's own children haven't necessarily rebuilt with the
      // new child widget yet at this point.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        void visit(Element element) {
          element.markNeedsBuild();
          element.visitChildren(visit);
        }
        context.visitChildElements(visit);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}