import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
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

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 2500), _routeNext);
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _routeNext() async {
    final onboardingSeen = !CacheManager.instance.isExpired(
          box: CacheKeys.settingsBox,
          key: CacheKeys.onboardingSeen,
          ttl: const Duration(days: 3650),
        ) &&
        (CacheManager.instance.read<bool>(
              box: CacheKeys.settingsBox,
              key: CacheKeys.onboardingSeen,
              fromJson: (json) => json as bool,
            ) ??
            false);

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (!onboardingSeen) {
      context.go(RouteNames.onboarding);
      return;
    }

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 5));
      final type = doc.data()?['type'] as String? ?? 'car_owner';
      if (!mounted) return;
      context.go(type == 'mechanic'
          ? RouteNames.mechanicHome
          : RouteNames.userHome);
    } catch (_) {
      if (!mounted) return;
      context.go(RouteNames.userHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Logo centered
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Red radial glow
                    Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x18E8281E),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Full logo
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

            // Spinner at bottom
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