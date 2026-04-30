import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../navigation/main_navigation.dart';
import '../vehicle/first_vehicle_screen.dart';
import '../mechanic/mechanic_navigation.dart';
import '../../core/services/vehicle_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  String? _errorMessage;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    try {
      setState(() {
        _errorMessage = null;
        _isRetrying = true;
      });

      // Timeout after 8 seconds
      await Future.any([
        _performAuthCheck(),
        Future.delayed(const Duration(seconds: 8), () => throw TimeoutException('Network timeout')),
      ]);

      if (!mounted) return;
      setState(() => _isRetrying = false);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No network access.\nPlease check your internet connection and try again.';
        _isRetrying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error.\nPlease check your internet and try again.';
        _isRetrying = false;
      });
    }
  }

  Future<void> _performAuthCheck() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('account_type')
            .eq('id', userId)
            .maybeSingle();

        final accountType = profile?['account_type'] ?? 'car_owner';

        if (!mounted) return;

        if (accountType == 'mechanic') {
          _navigate(const MechanicNavigation());
        } else {
          final hasVehicles = await VehicleService().hasVehicles();
          if (!mounted) return;
          _navigate(hasVehicles
              ? MainNavigation()
              : const FirstVehicleScreen());
        }
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      _navigate(const LoginScreen());
    } else {
      _navigate(const OnboardingScreen());
    }
  }

  void _navigate(Widget destination) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFE59A12),
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _isRetrying ? null : _checkAuthStatus,
                  child: Opacity(
                    opacity: _isRetrying ? 0.6 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0272D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isRetrying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/standiag-namelogo.png',
                  width: 240,
                  errorBuilder: (_, __, ___) =>
                      const _DrawnLogo(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawnLogo extends StatelessWidget {
  const _DrawnLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: const [
            Text('Stan',
                style: TextStyle(
                    fontSize: 64, fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic, color: Colors.white,
                    letterSpacing: -2, height: 1, fontFamily: 'Inter')),
            Text('Diag',
                style: TextStyle(
                    fontSize: 64, fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFC0272D),
                    letterSpacing: -2, height: 1, fontFamily: 'Inter')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Wing(left: true),
            const SizedBox(width: 10),
            const Text('AUTO',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Color(0xFFC0272D),
                    letterSpacing: 6, fontFamily: 'Inter')),
            const SizedBox(width: 10),
            _Wing(left: false),
          ],
        ),
      ],
    );
  }
}

class _Wing extends StatelessWidget {
  final bool left;
  const _Wing({required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72, height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: left ? Alignment.centerRight : Alignment.centerLeft,
          end: left ? Alignment.centerLeft : Alignment.centerRight,
          colors: const [Color(0xFFC0272D), Colors.transparent],
        ),
      ),
    );
  }
}
