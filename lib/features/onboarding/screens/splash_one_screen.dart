// Splash One — the system splash screen.
// Shows immediately when the app launches.
// Contains only the logo icon centered on the app background.
// Navigates to Splash Two after a short delay.
// The OS status bar is styled light (white icons) via SystemUiStyle.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

class SplashOneScreen extends StatefulWidget {
  const SplashOneScreen({super.key});

  @override
  State<SplashOneScreen> createState() => _SplashOneScreenState();
}

class _SplashOneScreenState extends State<SplashOneScreen> {
  @override
  void initState() {
    super.initState();

    // Apply white status bar icons — app background is dark
    SystemUiStyle.applyDark();

    // Navigate to Splash Two after a short hold so the icon is visible
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(RouteNames.splashTwo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // No AppBar — full screen, status bar styled by SystemUiStyle
      body: SafeArea(
        // SafeArea keeps content below the status bar
        child: Center(
          child: Image.asset(
            // Logo icon — ECG + wrench mark, no text
            'assets/images/logo_icon.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}