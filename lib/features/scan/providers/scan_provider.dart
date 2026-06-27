// Scan provider — owns OBD scan results and scan history.
// Scan history is cached in Hive for 24 hours.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_model.dart';

class ScanState {
  final List<ScanModel> history;
  final ScanModel? latestScan;
  final bool isScanning;
  final bool isConnected;
  final String? error;

  const ScanState({
    this.history = const [],
    this.latestScan,
    this.isScanning = false,
    this.isConnected = false,
    this.error,
  });

  ScanState copyWith({
    List<ScanModel>? history,
    ScanModel? latestScan,
    bool? isScanning,
    bool? isConnected,
    String? error,
  }) {
    return ScanState(
      history: history ?? this.history,
      latestScan: latestScan ?? this.latestScan,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(const ScanState());

  Future<void> connectObd() async {
    // TODO: use flutter_blue_plus to scan for BLE devices and connect to OBD adapter
    state = state.copyWith(isConnected: true);
  }

  Future<void> startScan(String vehicleId, String ownerId) async {
    state = state.copyWith(isScanning: true, error: null);
    try {
      // TODO: send OBD-II commands, parse response, calculate health score
      await Future.delayed(const Duration(seconds: 3));
      state = state.copyWith(isScanning: false);
    } catch (e) {
      state = state.copyWith(isScanning: false, error: e.toString());
    }
  }

  Future<void> fetchHistory(String ownerId) async {
    try {
      // TODO: fetch from Firestore scans collection where ownerId == ownerId
      state = state.copyWith(history: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final scanProvider =
    StateNotifierProvider<ScanNotifier, ScanState>((ref) => ScanNotifier());