// Mechanic Card screen — shows found mechanic card (locked state).
// Map background, mechanic info card at bottom, Subscribe/Call buttons.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicCardScreen extends StatefulWidget {
  const MechanicCardScreen({super.key});

  @override
  State<MechanicCardScreen> createState() => _MechanicCardScreenState();
}

class _MechanicCardScreenState extends State<MechanicCardScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          Container(
            color: AppColors.mapBackground,
            child: const Center(
              child: Icon(Icons.map_outlined,
                  size: 80, color: AppColors.borderSubtle),
            ),
          ),

          // Top gradient
          Positioned(
            top: 0, left: 0, right: 0, height: 140,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF0060606), Colors.transparent],
                ),
              ),
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xB3080808),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: const Color(0x1FFFFFFF)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Mechanic Found',
                        style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xB3080808),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: const Icon(Icons.search_rounded,
                        size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 20,
                  AppSpacing.pageHorizontal, 36),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl5)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AppAvatar(name: 'Kwame Asante', size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kwame Asante',
                                style: AppTypography.heading4,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            const SizedBox(height: 3),
                            Row(
                              children: const [
                                RatingStars(rating: 4.9, starSize: 12),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text('4.9 · 312 jobs',
                                      style: AppTypography.caption,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: const [
                                Flexible(child: ExpertiseTag(label: 'Engine')),
                                SizedBox(width: 4),
                                Flexible(child: ExpertiseTag(label: 'Transmission')),
                                SizedBox(width: 4),
                                Flexible(child: ExpertiseTag(label: 'Electrical')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('1.2 km',
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary),
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                          const SizedBox(height: 2),
                          const StatusDot(isOnline: true, size: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'View Profile',
                          onTap: () => context.go(RouteNames.mechanicProfile),
                          variant: AppButtonVariant.ghost,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          label: 'Call Mechanic',
                          onTap: () => context.go(RouteNames.inAppCall),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}