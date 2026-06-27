// User Profile screen — view mode showing user details and vehicles.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(RouteNames.userHome),
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
                  const Expanded(child: Text('My Profile',
                      style: AppTypography.heading3,
                      overflow: TextOverflow.ellipsis, maxLines: 1)),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Edit',
                        style: AppTypography.body.copyWith(
                            color: AppColors.primary),
                        overflow: TextOverflow.ellipsis, maxLines: 1)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  children: [
                    const AppAvatar(name: 'John Doe', size: 80),
                    const SizedBox(height: 12),
                    const Text('John Doe', style: AppTypography.heading2,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 4),
                    const Text('@johndoe', style: AppTypography.body,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 24),
                    const _InfoRow(label: 'Email', value: 'john@email.com'),
                    const _InfoRow(label: 'Phone', value: '+234 800 000 0000'),
                    const _InfoRow(label: 'Address', value: '14 Park Avenue, Lekki'),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context.go(RouteNames.myVehicles),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.border)),
                        child: const Row(children: [
                          Icon(Icons.directions_car_outlined,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 12),
                          Expanded(child: Text('My Vehicles',
                              style: AppTypography.bodyLarge,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted, size: 18),
                        ]),
                      ),
                    ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: AppTypography.caption,
                overflow: TextOverflow.ellipsis, maxLines: 1)),
          Expanded(child: Text(value, style: AppTypography.body,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
        ],
      ),
    );
  }
}