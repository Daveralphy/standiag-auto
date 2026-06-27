// Profile provider — owns user/mechanic profile data and vehicle list.
// Profile is cached in Hive until logout or explicit update.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vehicle_model.dart';

class ProfileState {
  final List<VehicleModel> vehicles;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProfileState({
    this.vehicles = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  ProfileState copyWith({
    List<VehicleModel>? vehicles,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return ProfileState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  Future<void> fetchVehicles(String ownerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: fetch from Firestore vehicles where ownerId == ownerId
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false, vehicles: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      // TODO: write to Firestore vehicles collection
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(
        isSaving: false,
        vehicles: [...state.vehicles, vehicle],
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      // TODO: delete from Firestore vehicles/{vehicleId}
      state = state.copyWith(
        vehicles: state.vehicles.where((v) => v.id != vehicleId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
        (ref) => ProfileNotifier());