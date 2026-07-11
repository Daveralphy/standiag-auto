// Shared top header for every tab screen (Home / Scan / Mechanics-or-Users),
// for both CarOwner and Mechanic. Same avatar-opens-drawer affordance, same
// two-line title shape, same trailing icon button style — so all three tabs
// read as one cohesive section instead of three different-looking screens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../providers/user_provider.dart';
import 'app_avatar.dart';
import 'app_skeleton.dart';

class AppScreenHeader extends ConsumerWidget {
  /// The screen's Scaffold key — tapping the avatar opens its drawer.
  final GlobalKey<ScaffoldState> scaffoldKey;

  /// When true, the title becomes "Hi, {firstName} 👋" resolved from the
  /// signed-in profile. When false, [title] is shown verbatim.
  final bool showGreeting;
  final String? title;
  final String subtitle;

  final IconData trailingIcon;
  final VoidCallback? onTrailingTap;

  static const double avatarSize = 48;
  static const double iconButtonSize = 44;

  const AppScreenHeader({
    super.key,
    required this.scaffoldKey,
    required this.subtitle,
    required this.trailingIcon,
    this.showGreeting = false,
    this.title,
    this.onTrailingTap,
  }) : assert(showGreeting || title != null,
            'title is required when showGreeting is false');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: userAsync.when(
              data: (user) => AppAvatar(
                name: (user?.firstName.isNotEmpty ?? false)
                    ? user!.firstName
                    : '?',
                size: avatarSize,
              ),
              loading: () => const AppSkeleton.circle(size: avatarSize),
              error: (_, __) => const AppAvatar(name: '?', size: avatarSize),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showGreeting
                      ? userAsync.when(
                          data: (user) =>
                              'Hi, ${(user?.firstName.isNotEmpty ?? false) ? user!.firstName : 'there'} 👋',
                          loading: () => '',
                          error: (_, __) => 'Hi, there 👋',
                        )
                      : title!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTrailingTap,
            child: Container(
              width: iconButtonSize,
              height: iconButtonSize,
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(trailingIcon, size: 20, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
