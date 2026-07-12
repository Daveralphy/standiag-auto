// Notifications screen — list of in-app notifications for the signed-in user.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;
      ref.read(notificationsProvider.notifier).fetch(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationsState>(notificationsProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

    final state = ref.watch(notificationsProvider);
    final type = ref.watch(currentUserTypeProvider);

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
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.homeFor(type));
                    }
                  },
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
                const Expanded(child: Text(AppStrings.notificationsTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading && state.notifications.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, __) => const _NotificationSkeleton(),
                    )
                  : state.notifications.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Color(0x33FFFFFF), size: 48),
                                const SizedBox(height: 16),
                                const Text(
                                    AppStrings.notificationsEmptyTitle,
                                    style: AppTypography.heading3),
                                const SizedBox(height: 8),
                                const Text(
                                    AppStrings.notificationsEmptyBody,
                                    style: AppTypography.body,
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          itemCount: state.notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              _NotificationCard(item: state.notifications[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  const _NotificationCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case NotificationType.job:
        return Icons.build_outlined;
      case NotificationType.credits:
        return Icons.monetization_on_outlined;
      case NotificationType.system:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(
            color: item.isRead ? AppColors.border : AppColors.primaryBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primaryBorder)),
            child: Icon(_icon, color: AppColors.primary, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 3),
                Text(item.body,
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis, maxLines: 2),
                const SizedBox(height: 4),
                Text(Formatters.relativeDate(item.createdAt),
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
          if (!item.isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton.circle(size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 13,
                    decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 180, height: 12,
                    decoration: BoxDecoration(color: const Color(0x0AFFFFFF),
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
