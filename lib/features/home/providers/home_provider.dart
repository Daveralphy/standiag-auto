// Home provider — owns the data shown on both user and mechanic home screens.
// Fetches from Firestore and keeps the last fetch timestamp in Hive.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/errors/error_handler.dart';
import '../../auth/models/user_model.dart';

class HomeState {
  final bool isLoading;
  final UserModel? profile;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  HomeState copyWith({bool? isLoading, UserModel? profile, String? error}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('No authenticated user');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!snapshot.exists) {
        throw StateError('User profile not found');
      }

      final profile = UserModel.fromFirestore(snapshot);
      await CacheManager.instance.write(
          box: CacheKeys.settingsBox,
          key: CacheKeys.homeLastFetch,
          value: DateTime.now().toIso8601String());
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }
}

final homeProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier());