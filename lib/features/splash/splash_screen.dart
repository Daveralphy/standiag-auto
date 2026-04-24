import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

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
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
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
                // Try PNG logo first, fallback to drawn logo
                Image.asset(
                  'assets/images/standiag-namelogo.png',
                  width: 240,
                  errorBuilder: (_, __, ___) => _DrawnLogo(),
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
                  fontStyle: FontStyle.italic, color: Color(0xFFC0272D),
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
                  color: Color(0xFFC0272D), letterSpacing: 6,
                  fontFamily: 'Inter',
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
