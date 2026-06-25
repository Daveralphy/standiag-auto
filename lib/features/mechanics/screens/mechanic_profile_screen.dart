// Mechanic Profile screen — full profile view shown to car owners.
// Accessed from mechanic card or search results.

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

class MechanicProfileScreen extends StatefulWidget {
  const MechanicProfileScreen({super.key});

  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Mechanic Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border)),
                      child: Column(children: [
                        AppAvatar(name: 'Kwame Asante', size: 72),
                        const SizedBox(height: 12),
                        Text('Kwame Asante',
                            style: AppTypography.heading2,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            RatingStars(rating: 4.9),
                            SizedBox(width: 6),
                            Flexible(child: Text('4.9 · 312 jobs · 8 yrs',
                                style: AppTypography.caption,
                                overflow: TextOverflow.ellipsis, maxLines: 1)),
                          ]),
                        const SizedBox(height: 12),
                        Wrap(spacing: 6, runSpacing: 6, children: const [
                          ExpertiseTag(label: 'Engine Repair'),
                          ExpertiseTag(label: 'Transmission'),
                          ExpertiseTag(label: 'Electrical'),
                          ExpertiseTag(label: 'Brakes'),
                          ExpertiseTag(label: 'AC Repair'),
                        ]),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: 12),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(child: Text('14 Park Avenue, Lekki',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const StatusDot(isOnline: true, size: 8),
                          const SizedBox(width: 6),
                          Text('Online · 1.2 km away',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Call Mechanic',
                      onTap: () => context.go(RouteNames.inAppCall),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}