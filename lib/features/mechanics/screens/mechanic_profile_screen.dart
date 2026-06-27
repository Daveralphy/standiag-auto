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
                  onTap: () => context.go(RouteNames.mechanicCard),
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
                const Expanded(child: Text('Mechanic Profile',
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
                      child: const Column(children: [
                        AppAvatar(name: 'Kwame Asante', size: 72),
                        SizedBox(height: 12),
                        Text('Kwame Asante',
                            style: AppTypography.heading2,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatingStars(rating: 4.9),
                            SizedBox(width: 6),
                            Flexible(child: Text('4.9 · 312 jobs · 8 yrs',
                                style: AppTypography.caption,
                                overflow: TextOverflow.ellipsis, maxLines: 1)),
                          ]),
                        SizedBox(height: 12),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          ExpertiseTag(label: 'Engine Repair'),
                          ExpertiseTag(label: 'Transmission'),
                          ExpertiseTag(label: 'Electrical'),
                          ExpertiseTag(label: 'Brakes'),
                          ExpertiseTag(label: 'AC Repair'),
                        ]),
                        SizedBox(height: 12),
                        Divider(color: AppColors.borderSubtle),
                        SizedBox(height: 12),
                        Row(children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          SizedBox(width: 4),
                          Expanded(child: Text('14 Park Avenue, Lekki',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ]),
                        SizedBox(height: 6),
                        Row(children: [
                          StatusDot(isOnline: true, size: 8),
                          SizedBox(width: 6),
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