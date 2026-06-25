// User Rate Mechanic screen — user taps stars and leaves optional comment.
// Map background, user nav Mechanics active, search icon top right.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserRateMechanicScreen extends StatefulWidget {
  const UserRateMechanicScreen({super.key});

  @override
  State<UserRateMechanicScreen> createState() =>
      _UserRateMechanicScreenState();
}

class _UserRateMechanicScreenState extends State<UserRateMechanicScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          Container(color: AppColors.mapBackground,
              child: const Center(child: Icon(Icons.map_outlined,
                  size: 80, color: AppColors.borderSubtle))),

          Positioned(top: 0, left: 0, right: 0, height: 140,
            child: Container(decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF0060606), Colors.transparent])))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                AppAvatar(name: 'John Doe', size: 36),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rate Mechanic', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('How was the job?', style: AppTypography.body,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                )),
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xB3080808),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: const Color(0x1FFFFFFF))),
                  child: const Icon(Icons.search_rounded,
                      size: 16, color: Colors.white)),
              ]),
            ),
          ),

          Positioned(
            bottom: AppSpacing.navBarClearance + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  AppAvatar(name: 'Kwame Asante', size: 46),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kwame Asante', style: AppTypography.heading4,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text('Engine Problem · Toyota Corolla 2019',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  )),
                ]),
                const SizedBox(height: 16),
                Text('Tap a star to rate',
                    style: AppTypography.bodySmall,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 12),
                // Star selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i < _rating
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Comment (optional)',
                  controller: _commentController,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: AppButton(
                    label: 'Skip',
                    onTap: () => context.go(RouteNames.userHome),
                    variant: AppButtonVariant.ghost,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton(
                    label: 'Submit',
                    onTap: () {
                      setState(() => _isLoading = true);
                      Future.delayed(const Duration(seconds: 1), () {
                        if (!context.mounted) return;
                        if (mounted) context.go(RouteNames.userHome);
                      });
                    },
                    isLoading: _isLoading,
                  )),
                ]),
              ]),
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () => context.go(RouteNames.userHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}