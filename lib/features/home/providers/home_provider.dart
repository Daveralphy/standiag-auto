// Home provider — owns the data shown on both user and mechanic home screens.
// Fetches from Firestore once and caches in Hive for the session.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';

class HomeState {
  final bool isLoading;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({bool? isLoading, String? error}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: fetch from Firestore when Firebase is configured
      await Future.delayed(const Duration(milliseconds: 800));
      await CacheManager.instance.write(
          box: CacheKeys.settingsBox,
          key: CacheKeys.homeLastFetch,
          value: DateTime.now().toIso8601String());
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier());