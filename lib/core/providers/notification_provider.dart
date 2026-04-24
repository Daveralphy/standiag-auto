import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(notificationServiceProvider).getNotifications();
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationServiceProvider).getUnreadCount();
});