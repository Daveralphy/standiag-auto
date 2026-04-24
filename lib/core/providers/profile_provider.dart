import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(profileServiceProvider).getProfile();
});

final scanCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(profileServiceProvider).getScanCount();
});

final lastScanProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(profileServiceProvider).getLastScan();
});