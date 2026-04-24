import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) => notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildList(notifications),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                ),
                error: (_, __) => _buildEmptyState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Notifications',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter')),
          ),
          GestureDetector(
            onTap: () async {
              await NotificationService().markAllRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: const Text('Mark all read',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              color: AppColors.textTertiary, size: 48),
          SizedBox(height: 16),
          Text('No notifications yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
          SizedBox(height: 6),
          Text(
              'You\'ll see scan results, maintenance\nreminders and updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  height: 1.5,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> notifications) {
    // Group by date
    final today = <Map<String, dynamic>>[];
    final yesterday = <Map<String, dynamic>>[];
    final earlier = <Map<String, dynamic>>[];

    final now = DateTime.now();

    for (final n in notifications) {
      final createdAt = DateTime.parse(n['created_at']).toLocal();
      final diff = now.difference(createdAt);

      if (diff.inDays == 0) {
        today.add(n);
      } else if (diff.inDays == 1) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        if (today.isNotEmpty) ...[
          _GroupLabel(label: 'TODAY'),
          const SizedBox(height: 10),
          ...today.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NotifRow(notification: n),
              )),
          const SizedBox(height: 12),
        ],
        if (yesterday.isNotEmpty) ...[
          _GroupLabel(label: 'YESTERDAY'),
          const SizedBox(height: 10),
          ...yesterday.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NotifRow(notification: n),
              )),
          const SizedBox(height: 12),
        ],
        if (earlier.isNotEmpty) ...[
          _GroupLabel(label: 'EARLIER'),
          const SizedBox(height: 10),
          ...earlier.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NotifRow(notification: n),
              )),
        ],
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
            fontFamily: 'Inter'));
  }
}

class _NotifRow extends StatelessWidget {
  final Map<String, dynamic> notification;
  const _NotifRow({required this.notification});

  IconData get _icon {
    switch (notification['type']) {
      case 'maintenance': return Icons.build_outlined;
      case 'scan': return Icons.wifi_tethering_rounded;
      case 'mechanic': return Icons.chat_outlined;
      case 'account': return Icons.person_outline_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification['type']) {
      case 'maintenance': return AppColors.moderate;
      case 'scan': return AppColors.advisory;
      case 'mechanic': return AppColors.whatsApp;
      case 'account': return AppColors.primary;
      default: return AppColors.bluetooth;
    }
  }

  Color get _iconBg {
    switch (notification['type']) {
      case 'maintenance': return AppColors.moderateBg;
      case 'scan': return AppColors.advisoryBg;
      case 'mechanic':
        return AppColors.whatsApp.withValues(alpha: 0.12);
      case 'account': return AppColors.primarySubtle;
      default:
        return AppColors.bluetooth.withValues(alpha: 0.12);
    }
  }

  String _timeAgo(String createdAt) {
    final dt = DateTime.parse(createdAt).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification['is_read'] == false;
    final type = notification['type'] ?? 'general';
    final createdAt = notification['created_at'] ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.surfaceDeep : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isUnread ? AppColors.border : AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUnread)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8),
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    color: _iconColor, shape: BoxShape.circle),
              ),
            )
          else
            const SizedBox(width: 15),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(_icon, color: _iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 3),
                Text(notification['body'] ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        color: isUnread
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(
                    '${_capitalise(type)}  •  ${_timeAgo(createdAt)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
