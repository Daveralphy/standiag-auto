// Profile provider — owns user/mechanic profile data and vehicle list.
// Profile data is written to Firestore and mirrored in Hive.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/errors/error_handler.dart';

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
      final query = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      final vehicles = query.docs.map(VehicleModel.fromFirestore).toList();
      await CacheManager.instance.write(
        box: CacheKeys.vehiclesBox,
        key: CacheKeys.vehicles,
        value: vehicles.map((vehicle) => vehicle.toFirestore()).toList(),
      );
      state = state.copyWith(isLoading: false, vehicles: vehicles);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final doc = FirebaseFirestore.instance.collection('vehicles').doc();
      final storedVehicle = VehicleModel(
        id: doc.id,
        ownerId: vehicle.ownerId,
        make: vehicle.make,
        model: vehicle.model,
        year: vehicle.year,
        type: vehicle.type,
        colour: vehicle.colour,
        plateNumber: vehicle.plateNumber,
        fuelType: vehicle.fuelType,
      );
      await doc.set(storedVehicle.toFirestore());
      state = state.copyWith(
        isSaving: false,
        vehicles: [...state.vehicles, storedVehicle],
      );
      await CacheManager.instance.write(
        box: CacheKeys.vehiclesBox,
        key: CacheKeys.vehicles,
        value: state.vehicles.map((item) => item.toFirestore()).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).delete();
      state = state.copyWith(
        vehicles: state.vehicles.where((v) => v.id != vehicleId).toList(),
      );
      await CacheManager.instance.write(
        box: CacheKeys.vehiclesBox,
        key: CacheKeys.vehicles,
        value: state.vehicles.map((item) => item.toFirestore()).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
        (ref) => ProfileNotifier());