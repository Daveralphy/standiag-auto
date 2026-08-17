// Splash One — stands in for the native OS launch screen until this app
// has a real one configured (see README "Known open items"). Advances as
// soon as the first frame lands — no artificial hold — since its only job
// is to paint the brand mark while Flutter finishes initializing.
// The OS status bar is styled light (white icons) via SystemUiStyle.
//
// Deliberately pinned to AppColors.dark rather than the current theme —
// the logo art (assets/images/logo_icon.png) was only ever designed against
// a dark background, so this screen always renders dark regardless of the
// user's Appearance setting.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

    // Apply white status bar icons — this screen is always dark
    SystemUiStyle.applyDark();

    // Advance right after the first frame renders — just enough for the
    // logo to actually paint once, with no artificial delay after that.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(RouteNames.splashTwo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark.background,
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