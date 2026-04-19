import 'package:flutter/material.dart';
import '../home/home_shell.dart';

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
            pageBuilder: (_, __, ___) => const HomeShell(),
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
                // StanDiag wordmark
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      'Stan',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Diag',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFC0272D),
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // AUTO with wing lines
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WingLine(fadeToRight: true),
                    const SizedBox(width: 10),
                    const Text(
                      'AUTO',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC0272D),
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _WingLine(fadeToRight: false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WingLine extends StatelessWidget {
  final bool fadeToRight;
  const _WingLine({required this.fadeToRight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: fadeToRight ? Alignment.centerLeft : Alignment.centerRight,
          end: fadeToRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: const [
            Colors.transparent,
            Color(0xFFC0272D),
          ],
        ),
      ),
    );
  }
}
