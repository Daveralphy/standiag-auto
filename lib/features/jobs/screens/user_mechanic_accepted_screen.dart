// User Mechanic Accepted screen — mechanic has accepted the job.
// Secondary screen — back button, no nav bar, no avatar in header.
// Map background showing mechanic en route.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserMechanicAcceptedScreen extends StatefulWidget {
  const UserMechanicAcceptedScreen({super.key});

  @override
  State<UserMechanicAcceptedScreen> createState() =>
      _UserMechanicAcceptedScreenState();
}

class _UserMechanicAcceptedScreenState
    extends State<UserMechanicAcceptedScreen> {
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
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xB3080808),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: const Color(0x1FFFFFFF))),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: Colors.white)),
              ),
            ),
          ),

          Positioned(
            bottom: 40, left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  // Success banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x144CAF50),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: const Color(0x334CAF50))),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mechanic accepted!',
                              style: AppTypography.bodyLarge,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                          Text("He's on his way to you",
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ],
                      )),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    AppAvatar(name: 'Kwame Asante', size: 42),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kwame Asante', style: AppTypography.heading4,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text('7 min away · 1.2 km',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.primary),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'Live · Tap to track',
                    onTap: () => context.go(RouteNames.userTracking),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}