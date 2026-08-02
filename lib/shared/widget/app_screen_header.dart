// Shared top header for every tab screen (Home / Scan / Mechanics-or-Users),
// for both CarOwner and Mechanic. Same avatar-opens-drawer affordance, same
// two-line title shape, same trailing icon button style — so all three tabs
// read as one cohesive section instead of three different-looking screens.
//
// The two map screens (User Mechanics, Mechanic Users) also use this same
// header for their search-by-name affordance via [isSearching]: the avatar
// and layout stay pixel-identical, only the title area becomes a live text
// field and the trailing icon becomes a close button — so tapping search
// never feels like a different screen, just this one with the keyboard up.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../providers/user_provider.dart';
import 'app_avatar.dart';
import 'app_badge.dart';
import 'app_skeleton.dart';

class AppScreenHeader extends ConsumerWidget {
  /// The screen's Scaffold key — tapping the avatar opens its drawer. Null
  /// on screens with no drawer (and no avatar shown at all): title/subtitle
  /// then start flush at the leading edge instead.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  /// When true, the title becomes "Hi, {firstName} 👋" resolved from the
  /// signed-in profile. When false, [title] is shown verbatim.
  final bool showGreeting;
  final String? title;
  final String subtitle;

  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  /// Shows a small red dot on the trailing icon and lights the icon itself
  /// up in the primary color instead of muted grey — used to mark the
  /// trailing action as having something live to show (e.g. an active job)
  /// rather than being an empty, inert state.
  final bool trailingBadge;

  /// Replaces the trailing icon button entirely with an arbitrary widget
  /// (e.g. a credit-balance pill) that manages its own tap — used when the
  /// trailing action isn't representable as a single icon. The rest of the
  /// header (padding, avatar, title/subtitle) stays pixel-identical either
  /// way, so screens that need this still look like the same header, not
  /// a different one.
  final Widget? trailingWidget;

  /// When true, the title/subtitle area becomes a live search field and the
  /// trailing button becomes a close (X) button. Requires
  /// [searchController], [onSearchChanged] and [onSearchClose].
  final bool isSearching;
  final TextEditingController? searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClose;

  static const double avatarSize = 48;
  static const double iconButtonSize = 44;

  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 23,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  const AppScreenHeader({
    super.key,
    this.scaffoldKey,
    required this.subtitle,
    this.trailingIcon,
    this.showGreeting = false,
    this.title,
    this.onTrailingTap,
    this.trailingBadge = false,
    this.trailingWidget,
    this.isSearching = false,
    this.searchController,
    this.searchHint = 'Search',
    this.onSearchChanged,
    this.onSearchClose,
  })  : assert(showGreeting || title != null,
            'title is required when showGreeting is false'),
        assert(trailingWidget != null || trailingIcon != null,
            'either trailingIcon or trailingWidget is required'),
        assert(
            !isSearching ||
                (searchController != null &&
                    onSearchChanged != null &&
                    onSearchClose != null),
            'searchController, onSearchChanged and onSearchClose are required when isSearching is true');

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
          if (scaffoldKey != null) ...[
            GestureDetector(
              onTap: () => scaffoldKey!.currentState?.openDrawer(),
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
          ],
          Expanded(
            child: isSearching
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: onSearchChanged,
                    style: _titleStyle,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: searchHint,
                      hintStyle: _titleStyle.copyWith(
                          color: AppColors.textMuted, fontWeight: FontWeight.w700),
                    ),
                  )
                : Column(
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
                        style: _titleStyle,
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
          if (trailingWidget != null && !isSearching)
            trailingWidget!
          else
            GestureDetector(
              onTap: isSearching ? onSearchClose : onTrailingTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: iconButtonSize,
                    height: iconButtonSize,
                    decoration: BoxDecoration(
                      color: const Color(0x08FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: trailingBadge && !isSearching
                            ? AppColors.primaryBorder
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(
                        isSearching ? Icons.close_rounded : trailingIcon,
                        size: 20,
                        color: trailingBadge && !isSearching
                            ? AppColors.primary
                            : AppColors.textMuted),
                  ),
                  if (trailingBadge && !isSearching)
                    const Positioned(top: 2, right: 2, child: NotificationDot()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
