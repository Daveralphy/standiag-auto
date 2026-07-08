// Scan provider — owns OBD scan results and scan history.
// Scan history is written to Firestore and mirrored in Hive.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/errors/error_handler.dart';

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
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw StateError('Bluetooth is disabled');
      }
      state = state.copyWith(isConnected: true, error: null);
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> startScan(String vehicleId, String ownerId) async {
    state = state.copyWith(isScanning: true, error: null);
    try {
      if (!state.isConnected) {
        await connectObd();
      }
      if (!state.isConnected) {
        throw StateError('OBD connection failed');
      }

      final scan = ScanModel(
        id: FirebaseFirestore.instance.collection('scans').doc().id,
        ownerId: ownerId,
        vehicleId: vehicleId,
        healthScore: 8,
        rawData: const {
          'adapterState': 'connected',
          'source': 'bluetooth',
        },
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('scans').doc(scan.id).set(
            scan.toFirestore(),
          );
      final updatedHistory = [scan, ...state.history];
      await CacheManager.instance.write(
        box: CacheKeys.scansBox,
        key: CacheKeys.scanHistory,
        value: updatedHistory.map((item) => item.toFirestore()).toList(),
      );
      state = state.copyWith(
        isScanning: false,
        latestScan: scan,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> fetchHistory(String ownerId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('scans')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
      final history = query.docs.map(ScanModel.fromFirestore).toList();
      await CacheManager.instance.write(
        box: CacheKeys.scansBox,
        key: CacheKeys.scanHistory,
        value: history.map((item) => item.toFirestore()).toList(),
      );
      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }
}

final scanProvider =
    StateNotifierProvider<ScanNotifier, ScanState>((ref) => ScanNotifier());