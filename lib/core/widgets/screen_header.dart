import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? actionIcon;
  final VoidCallback? onActionTap;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionIcon,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                    height: 1.2,
                  )),
                const SizedBox(height: 3),
                Text(subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  )),
              ],
            ),
          ),
          if (actionIcon != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onActionTap,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: actionIcon,
              ),
            ),
        ],
      ),
    );
  }
}

// Notification icon with unread badge
class NotifIcon extends StatelessWidget {
  final int unreadCount;
  const NotifIcon({super.key, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined,
            color: AppColors.textPrimary, size: 20),
        if (unreadCount > 0)
          Positioned(
            top: -4, right: -4,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

