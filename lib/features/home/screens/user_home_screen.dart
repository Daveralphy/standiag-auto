// User Home screen — the main dashboard for car owners.
// Shows greeting, diagnose car button, and nearby mechanics list.
// Nav bar: Scan (left) | Home (center, active) | Mechanics (right).
// Bell icon top right for notifications.

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

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
                // ─── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, John 👋',
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
                      // Bell icon
                      Container(
                        width: AppSpacing.iconButtonSize,
                        height: AppSpacing.iconButtonSize,
                        decoration: BoxDecoration(
                          color: const Color(0x08FFFFFF),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
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
                        // ─── Diagnose Car card ─────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: GestureDetector(
                            onTap: () => context.go(RouteNames.userScan),
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
                                  Text(
                                    "Let's Diagnose",
                                    style: AppTypography.heading2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Your Vehicle',
                                    style: AppTypography.heading2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to scan your car with OBD',
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

                        // ─── Nearby Mechanics section ──────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Great Mechanics',
                                      style: AppTypography.heading3,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      'Standby Nearby',
                                      style: AppTypography.body,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go(RouteNames.userMechanics),
                                child: Text(
                                  'See all',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Mechanic cards list — skeleton while loading
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Column(
                            children: const [
                              MechanicCardSkeleton(),
                              SizedBox(height: 10),
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

          // ─── Floating Nav Bar ──────────────────────────────────────────
          AppNavBar(
            activeItem: NavBarItem.home,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () {},
            onThirdTap: () => context.go(RouteNames.userMechanics),
          ),
        ],
      ),
    );
  }
}