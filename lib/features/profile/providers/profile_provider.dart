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

  Future<void> fetchVehicles(String ownerId, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        !CacheManager.instance.isExpired(
          box: CacheKeys.vehiclesBox,
          key: CacheKeys.vehicles,
          ttl: CacheTTL.vehicles,
        )) {
      final cached = CacheManager.instance.read<List<VehicleModel>>(
        box: CacheKeys.vehiclesBox,
        key: CacheKeys.vehicles,
        fromJson: (json) => (json as List)
            .map((entry) => VehicleModel.fromCache(
                Map<String, dynamic>.from(entry as Map)))
            .where((vehicle) => vehicle.ownerId == ownerId)
            .toList(),
      );
      if (cached != null) {
        state = state.copyWith(isLoading: false, vehicles: cached);
        return;
      }
    }

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
        value: vehicles.map((vehicle) => vehicle.toCache()).toList(),
      );
      state = state.copyWith(isLoading: false, vehicles: vehicles);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, StackTrace.current,
                screen: 'ProfileProvider.fetchVehicles')
            .message,
      );
    }
  }

  /// Returns true on success, false on failure — callers should only
  /// navigate away on true, not assume the write succeeded just because
  /// the future completed (it always completes; errors go to state.error).
  Future<bool> addVehicle(VehicleModel vehicle) async {
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
        value: state.vehicles.map((item) => item.toCache()).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: ErrorHandler.handle(e, StackTrace.current,
                screen: 'ProfileProvider.addVehicle')
            .message,
      );
      return false;
    }
  }

  /// Updates an existing vehicle's fields. Returns true on success, false
  /// on failure (see [addVehicle]'s doc for why callers must check this
  /// instead of assuming the write succeeded once the future completes).
  Future<bool> updateVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toFirestore());
      state = state.copyWith(
        isSaving: false,
        vehicles: [
          for (final v in state.vehicles)
            if (v.id == vehicle.id) vehicle else v,
        ],
      );
      await CacheManager.instance.write(
        box: CacheKeys.vehiclesBox,
        key: CacheKeys.vehicles,
        value: state.vehicles.map((item) => item.toCache()).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: ErrorHandler.handle(e, StackTrace.current,
                screen: 'ProfileProvider.updateVehicle')
            .message,
      );
      return false;
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
        value: state.vehicles.map((item) => item.toCache()).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current,
                screen: 'ProfileProvider.deleteVehicle')
            .message,
      );
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
        (ref) => ProfileNotifier());

/// One-time fetch of a single vehicle by id — used wherever a job only
/// carries a vehicleId and the vehicle's make/model needs to be shown
/// (e.g. a mechanic's pending/active job tiles). Not real-time (Rule 13):
/// a vehicle's details rarely change mid-job.
final vehicleByIdProvider =
    FutureProvider.family<VehicleModel?, String>((ref, vehicleId) async {
  if (vehicleId.isEmpty) return null;
  final doc = await FirebaseFirestore.instance
      .collection('vehicles')
      .doc(vehicleId)
      .get();
  return doc.exists ? VehicleModel.fromFirestore(doc) : null;
});