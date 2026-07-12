// Notifications provider — fetches a user's in-app notifications.
// One-time fetch only, per project convention — notifications are not one of
// the allowed real-time cases (incoming calls / active job status / mechanic
// location), so this always reads with a one-time .get().

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../models/notification_model.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState());

  Future<void> fetch(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final notifications =
          query.docs.map(NotificationModel.fromFirestore).toList();
      state = state.copyWith(isLoading: false, notifications: notifications);
    } catch (e, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, stackTrace, screen: 'NotificationsProvider')
            .message,
      );
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
        (ref) => NotificationsNotifier());
