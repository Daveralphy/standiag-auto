// Splash Two — the branded app splash screen.
// Shows after Splash One while the app initialises.
// Contains the full logo (icon + wordmark + tagline) centered,
// a subtle red radial glow behind the logo,
// and a spinning circle loader at the bottom.
// Navigates to Onboarding after initialisation delay.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => _SplashTwoScreenState();
}

class _SplashTwoScreenState extends State<SplashTwoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();

    // Spinner animation — continuous rotation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Navigate to onboarding after app initialises
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go(RouteNames.onboarding);
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Logo centered in flex space ──────────────────────────────
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle red radial glow behind the logo
                    Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x12E8281E), // 7% red at center
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Full logo — icon + wordmark + tagline
                    Image.asset(
                      'assets/images/logo_full.png',
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Spinner at bottom ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 52),
              child: RotationTransition(
                turns: _spinController,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2.5,
                    ),
                  ),
                  // Clip to show only the top arc — creating spinner effect
                  child: ClipOval(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 28,
                        height: 14,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}