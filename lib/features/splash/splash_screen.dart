import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../navigation/main_navigation.dart';
import '../vehicle/first_vehicle_screen.dart';
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
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Already logged in — check vehicles
        final hasVehicles = await VehicleService().hasVehicles();
        if (!mounted) return;
        _navigate(hasVehicles
            ? MainNavigation()
            : const FirstVehicleScreen());
        return;
      }

      // Not logged in — check if onboarding has been seen before
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding =
          prefs.getBool('has_seen_onboarding') ?? false;

      if (!mounted) return;

      if (hasSeenOnboarding) {
        // Skip onboarding — go straight to login
        _navigate(const LoginScreen());
      } else {
        // First time ever — show onboarding
        _navigate(const OnboardingScreen());
      }
    });
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
                  errorBuilder: (_, __, ___) => const _DrawnLogo(),
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
                  letterSpacing: -2, height: 1, fontFamily: 'Inter',
                )),
            Text('Diag',
                style: TextStyle(
                  fontSize: 64, fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFC0272D),
                  letterSpacing: -2, height: 1, fontFamily: 'Inter',
                )),
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
                  letterSpacing: 6, fontFamily: 'Inter',
                )),
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

