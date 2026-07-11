// Streams the device's network connectivity state app-wide.
// Used by OfflineBanner (mounted once in app.dart) and by any screen with
// its own network-dependent bootstrap logic, e.g. splash_two_screen.dart.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits true once a network path exists, false when there is none.
/// Checks the current state immediately, then follows every change.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield hasConnection(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(hasConnection);
});

bool hasConnection(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);
