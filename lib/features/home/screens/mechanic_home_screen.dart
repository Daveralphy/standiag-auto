// Mechanic Home screen — dashboard for mechanics.
// Shows greeting, diagnose car button, and incoming job requests.
// Nav bar: Scan (left) | Home (center, active) | Users (right).
// Bell icon top right.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
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
                // ─── Header ─────────────────────────────────────────────
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
                              'Hi, Kwame 👋',
                              style: AppTypography.heading2,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              'Your Dashboard',
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
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.navBarClearance),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Diagnose Car card ───────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: GestureDetector(
                            onTap: () => context.go(RouteNames.mechanicScan),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryButtonGradient,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33E8281E),
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.qr_code_scanner_rounded,
                                      color: Colors.white, size: 28),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Scan Customer',
                                    style: AppTypography.heading2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const Text(
                                    'Vehicle',
                                    style: AppTypography.heading2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to diagnose a customer\'s car with OBD',
                                    style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Job Requests section ────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Text(
                            'Job Requests',
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Column(
                            children: [
                              MechanicCardSkeleton(),
                              SizedBox(height: 10),
                              MechanicCardSkeleton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.home,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () {},
            onThirdTap: () => context.go(RouteNames.mechanicUsers),
          ),
        ],
      ),
    );
  }
}