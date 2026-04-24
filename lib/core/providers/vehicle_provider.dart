import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vehicle_service.dart';

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  return VehicleService();
});

// ── Active Vehicle Provider ──────────────────────────────
final activeVehicleProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(vehicleServiceProvider).getActiveVehicle();
});

// ── All Vehicles Provider ────────────────────────────────
final userVehiclesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(vehicleServiceProvider).getUserVehicles();
});

// ── Has Vehicles Provider ────────────────────────────────
final hasVehiclesProvider = FutureProvider<bool>((ref) async {
  return ref.watch(vehicleServiceProvider).hasVehicles();
});