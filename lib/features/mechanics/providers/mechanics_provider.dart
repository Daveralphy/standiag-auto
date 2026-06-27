// Mechanics provider — owns the mechanic search results.
// Results are cached in Riverpod memory for the session duration.
// Only re-fetches on explicit refresh or session start.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mechanic_search_model.dart';

class MechanicsState {
  final List<MechanicSearchModel> mechanics;
  final bool isLoading;
  final bool isSearching;
  final double radiusKm;
  final String? error;

  const MechanicsState({
    this.mechanics = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.radiusKm = 1.0,
    this.error,
  });

  MechanicsState copyWith({
    List<MechanicSearchModel>? mechanics,
    bool? isLoading,
    bool? isSearching,
    double? radiusKm,
    String? error,
  }) {
    return MechanicsState(
      mechanics: mechanics ?? this.mechanics,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      radiusKm: radiusKm ?? this.radiusKm,
      error: error,
    );
  }
}

class MechanicsNotifier extends StateNotifier<MechanicsState> {
  MechanicsNotifier() : super(const MechanicsState());

  void setRadius(double km) {
    state = state.copyWith(radiusKm: km);
  }

  Future<void> search() async {
    state = state.copyWith(isSearching: true, error: null);
    try {
      // TODO: query Firestore mechanics collection filtered by isVisible + distance
      await Future.delayed(const Duration(seconds: 3));
      // Stub result for UI development
      state = state.copyWith(
        isSearching: false,
        mechanics: [
          const MechanicSearchModel(
            uid: 'stub-1',
            firstName: 'Kwame',
            lastName: 'Asante',
            workshopAddress: '14 Park Avenue, Lekki',
            expertise: ['Engine Repair', 'Transmission', 'Electrical'],
            rating: 4.9,
            totalJobs: 312,
            yearsOfExperience: 8,
            isVisible: true,
            distanceKm: 1.2,
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  void clear() {
    state = const MechanicsState();
  }
}

final mechanicsProvider =
    StateNotifierProvider<MechanicsNotifier, MechanicsState>(
        (ref) => MechanicsNotifier());