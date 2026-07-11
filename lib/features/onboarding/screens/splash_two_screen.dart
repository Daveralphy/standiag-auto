import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/system_ui_style.dart';

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => _SplashTwoScreenState();
}

class _SplashTwoScreenState extends State<SplashTwoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _startBootstrap();
  }

  Future<void> _startBootstrap() async {
    // Guarantee the brand mark gets a moment on screen before we ever
    // evaluate connectivity — so a fast-resolving check can never make the
    // offline state flash in before the logo has shown at all.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _checkConnectivityAndProceed();
  }

  Future<void> _checkConnectivityAndProceed() async {
    final hasConnection = await _hasConnection();
    if (!mounted) return;

    if (!hasConnection) {
      setState(() => _isOffline = true);
      _connectivitySubscription ??=
          Connectivity().onConnectivityChanged.listen((results) async {
        if (!_isConnected(results) || !mounted) return;
        // A network is reachable again — cancel this listener and retry
        // (re-checks connectivity before routing; no need to re-hold).
        await _connectivitySubscription?.cancel();
        _connectivitySubscription = null;
        setState(() => _isOffline = false);
        _checkConnectivityAndProceed();
      });
      return;
    }

    // Keeps the total on-screen time roughly the same as before (~2.5s)
    // for the common online case: 800ms hold + 1700ms here.
    Future.delayed(const Duration(milliseconds: 1700), _routeNext);
  }

  Future<bool> _hasConnection() async {
    try {
      return _isConnected(await Connectivity().checkConnectivity());
    } catch (_) {
      // If the platform channel itself fails, don't block the app on it.
      return true;
    }
  }

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  void dispose() {
    _spinController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _routeNext() async {
    final onboardingSeen = !CacheManager.instance.isExpired(
          box: CacheKeys.settingsBox,
          key: CacheKeys.onboardingSeen,
          ttl: const Duration(days: 3650),
        ) &&
        (CacheManager.instance.read<bool>(
              box: CacheKeys.settingsBox,
              key: CacheKeys.onboardingSeen,
              fromJson: (json) => json as bool,
            ) ??
            false);

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (!onboardingSeen) {
      context.go(RouteNames.onboarding);
      return;
    }

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    final type = await AuthController().fetchUserType(user.uid);
    if (!mounted) return;
    context.go(RouteNames.homeFor(type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Logo centered
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Red radial glow
                    Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x12E8281E),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                    // Full logo
                    Image.asset(
                      'assets/images/logo_full.png',
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            // Spinner or offline state at bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: SizedBox(
                height: 68,
                child: _isOffline ? _buildOfflineState() : _buildSpinner(),
              ),
            ),
            const SizedBox(height: 52),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _spinController,
        builder: (context, child) => CustomPaint(
          size: const Size(28, 28),
          painter: _SpinnerArcPainter(turns: _spinController.value),
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.textMuted, size: 22),
          const SizedBox(height: 8),
          const Text('No internet connection',
              style: AppTypography.body,
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 2),
          Text('Waiting to reconnect…',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }
}

// Matches the design's spinner: a faint full ring with one bright arc
// rotating continuously around it, instead of a rotating gap.
class _SpinnerArcPainter extends CustomPainter {
  final double turns;
  const _SpinnerArcPainter({required this.turns});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 2.5) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0x26E8281E);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = turns * 2 * math.pi - math.pi / 2;
    canvas.drawArc(rect, startAngle, math.pi / 2, false, arc);
  }

  @override
  bool shouldRepaint(covariant _SpinnerArcPainter oldDelegate) =>
      oldDelegate.turns != turns;
}