// Mechanic Job Completed screen — job done, shows customer rating received.
// Mechanic nav bar, Users active, search icon top right.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicJobCompletedScreen extends StatefulWidget {
  const MechanicJobCompletedScreen({super.key});

  @override
  State<MechanicJobCompletedScreen> createState() =>
      _MechanicJobCompletedScreenState();
}

class _MechanicJobCompletedScreenState
    extends State<MechanicJobCompletedScreen> {
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
              child: Row(children: [
                AppAvatar(name: 'Kwame Asante', size: 36),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Completed', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('Well done!', style: AppTypography.body.copyWith(
                        color: AppColors.success),
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
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
                      Text('Job completed!', style: AppTypography.bodyLarge,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text('Engine Problem · Toyota Corolla',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  )),
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  Row(children: [
                    AppAvatar(name: 'John Doe', size: 42),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Doe', style: AppTypography.heading4,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text('14 Park Avenue, Lekki',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 12),
                  Text('Customer rating', style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < 4 ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i < 4 ? AppColors.amber : AppColors.textDisabled,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text('"Great work, very professional!"',
                      style: AppTypography.bodySmall.copyWith(
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, maxLines: 2),
                ]),
              ),
            ]),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}