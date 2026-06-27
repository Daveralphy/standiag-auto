// Mechanic Scan screen — OBD diagnostic scan for mechanics.
// Nav bar active: Scan. Bell icon top right.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicScanScreen extends StatefulWidget {
  const MechanicScanScreen({super.key});

  @override
  State<MechanicScanScreen> createState() => _MechanicScanScreenState();
}

class _MechanicScanScreenState extends State<MechanicScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.homeMechanicScanTitle,
                              style: AppTypography.heading2,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              AppStrings.homeMechanicScanSubtitle,
                              style: AppTypography.body,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: AppSpacing.iconButtonSize,
                        height: AppSpacing.iconButtonSize,
                        decoration: BoxDecoration(
                          color: const Color(0x08FFFFFF),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            size: 16, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primarySubtle,
                            border: Border.all(
                                color: AppColors.primaryBorder, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33E8281E),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.primary,
                            size: 64,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        AppStrings.homeDiagnoseCar,
                        style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl),
                        child: Text(
                          AppStrings.homeOBDHint,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal),
                        child: AppButton(
                          label: AppStrings.homeDiagnoseCar,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.navBarClearance),
              ],
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.scan,
            userType: NavBarUserType.mechanic,
            onScanTap: () {},
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () => context.go(RouteNames.mechanicUsers),
          ),
        ],
      ),
    );
  }
}