import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_system.dart';

/// Standard header for all 4 main tab screens.
/// Full-width header with title + subtitle on left, icon button on right.
/// No padding - spans entire screen width.
class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  final VoidCallback? onActionTap;
  final bool titleHasPrimary; // if true, last word of title is primary color

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.onActionTap,
    this.titleHasPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTypography.bodySm,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            AppIconButton(icon: action!, onTap: onActionTap),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    if (!titleHasPrimary) {
      return Text(title,
        style: AppTypography.h2,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    // Split last word and color it primary
    final parts = title.split(' ');
    final last = parts.removeLast();
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTypography.h2,
        children: [
          TextSpan(text: '${parts.join(' ')} '),
          TextSpan(text: last,
            style: AppTypography.h2.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

/// Secondary header for pushed screens (back arrow + title + optional action)
/// Full-width header with no padding - spans entire screen width.
class AppSecondaryHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final VoidCallback? onActionTap;
  final VoidCallback? onBack;

  const AppSecondaryHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 18),
            onTap: onBack ?? () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
              style: AppTypography.h3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            AppIconButton(icon: action!, onTap: onActionTap),
          ],
        ],
      ),
    );
  }
}

/// Notification bell icon with optional unread badge
class NotifBell extends StatelessWidget {
  final int unreadCount;
  const NotifBell({super.key, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined,
            color: AppColors.textPrimary, size: 20),
        if (unreadCount > 0)
          Positioned(
            top: -6, right: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
