// Mechanic Profile screen (own view) — mechanic views their own profile.
// Lives in profile/screens/ — different from the user-facing mechanic
// profile in mechanics/screens/mechanic_profile_screen.dart.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicProfileOwnScreen extends StatefulWidget {
  const MechanicProfileOwnScreen({super.key});

  @override
  State<MechanicProfileOwnScreen> createState() =>
      _MechanicProfileOwnScreenState();
}

class _MechanicProfileOwnScreenState extends State<MechanicProfileOwnScreen> {
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
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
                Expanded(child: Text('My Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                GestureDetector(
                  onTap: () => context.go(RouteNames.mechanicProfileEdit),
                  child: Text('Edit',
                      style: AppTypography.body.copyWith(
                          color: AppColors.primary),
                      overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(children: [
                  AppAvatar(name: 'Kwame Asante', size: 80),
                  const SizedBox(height: 12),
                  Text('Kwame Asante', style: AppTypography.heading2,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      RatingStars(rating: 4.9),
                      SizedBox(width: 6),
                      Flexible(child: Text('4.9 · 312 jobs',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1)),
                    ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 6, runSpacing: 6, children: const [
                    ExpertiseTag(label: 'Engine Repair'),
                    ExpertiseTag(label: 'Transmission'),
                    ExpertiseTag(label: 'Electrical'),
                    ExpertiseTag(label: 'Brakes'),
                  ]),
                  const SizedBox(height: 24),
                  _InfoRow(label: 'Workshop', value: '14 Park Avenue, Lekki'),
                  _InfoRow(label: 'Experience', value: '8 years'),
                  _InfoRow(label: 'Phone', value: '+234 800 000 0000'),
                  _InfoRow(label: 'Email', value: 'kwame@email.com'),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        SizedBox(width: 80,
          child: Text(label, style: AppTypography.caption,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
        Expanded(child: Text(value, style: AppTypography.body,
            overflow: TextOverflow.ellipsis, maxLines: 1)),
      ]),
    );
  }
}