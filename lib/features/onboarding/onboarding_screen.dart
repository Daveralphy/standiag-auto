import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../auth/account_type_screen.dart';
import 'onboarding_slide_1.dart';
import 'onboarding_slide_2.dart';
import 'onboarding_slide_3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _markSeen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccountTypeScreen()),
      );
    }
  }

  void _skip() {
    _markSeen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _ctrl,
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          OnboardingSlide1(
            currentPage: _page,
            onNext: _next,
            onSkip: _skip,
          ),
          OnboardingSlide2(
            currentPage: _page,
            onNext: _next,
            onSkip: _skip,
          ),
          OnboardingSlide3(
            currentPage: _page,
            onNext: _next,
            onSkip: _skip,
          ),
        ],
      ),
    );
  }
}

