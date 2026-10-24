import 'package:flutter/material.dart';

import 'entry_screen.dart';

/// First-launch introduction. Users can swipe, skip, or advance with the CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      image: 'assets/images/onboarding_1.png',
      title: 'Help for your\nvehicle, anytime',
      accent: 'anytime',
      description:
          'Get trusted mechanics, real-time updates, and reliable service right from your phone.',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding_2.png',
      title: 'Trusted\nmechanics',
      accent: 'mechanics',
      description:
          'Connect with verified and skilled mechanics who can diagnose, repair and keep your vehicle on the road.',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding_3.png',
      title: 'Quality service\nwith confidence',
      accent: 'with confidence',
      description:
          'From diagnostics to repairs, get transparent quotes, track progress, and enjoy a smoother experience.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish({required bool createAccount}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => EntryScreen(initialIsCreatingAccount: createAccount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0C),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [
            for (var i = 0; i < _pages.length; i++)
              _OnboardingSlide(
                data: _pages[i],
                page: i,
                onSkip: () => _goTo(_pages.length),
                onNext: () => _goTo(i + 1),
              ),
            _WelcomeSlide(
              onCreateAccount: () => _finish(createAccount: true),
              onSignIn: () => _finish(createAccount: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.image,
    required this.title,
    required this.accent,
    required this.description,
  });

  final String image;
  final String title;
  final String accent;
  final String description;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.data,
    required this.page,
    required this.onSkip,
    required this.onNext,
  });

  final _OnboardingPageData data;
  final int page;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final titleParts = data.title.split(data.accent);
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.12,
          letterSpacing: -0.5,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(data.image, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.24, 0.48, 1],
                  colors: [
                    Color(0x44000000),
                    Color(0x08000000),
                    Color(0xCC050608),
                    Color(0xFF050608),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 15),
                ),
                child: const Text('Skip'),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 22,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.48,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: titleStyle,
                        children: [
                          TextSpan(text: titleParts.first),
                          TextSpan(
                            text: data.accent,
                            style: titleStyle?.copyWith(
                              color: const Color(0xFFEF233C),
                            ),
                          ),
                          if (titleParts.length > 1)
                            TextSpan(text: titleParts.last),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFF1F1F3),
                            height: 1.5,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        for (var dot = 0; dot < 3; dot++) ...[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: dot == page ? 11 : 8,
                            height: dot == page ? 11 : 8,
                            decoration: BoxDecoration(
                              color: dot == page
                                  ? const Color(0xFFEF233C)
                                  : const Color(0xFF9A9A9E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (dot < 2) const SizedBox(width: 12),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: IconButton.filled(
                            onPressed: onNext,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFEF233C),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            tooltip: 'Next',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({
    required this.onCreateAccount,
    required this.onSignIn,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF050608)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.sizeOf(context).height * 0.35,
          child: Image.asset(
            'assets/images/onboarding_3.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.46, 0.72, 1],
                colors: [
                  Color(0xFF050608),
                  Color(0xFF050608),
                  Color(0xEE050608),
                  Color(0x22050608),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo_full.png',
                    height: 116,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Standiag Auto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  const Text(
                    'Let’s get you started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Create an account to book services, track repairs and manage your vehicles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF1F1F3),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 58,
                    child: FilledButton(
                      onPressed: onCreateAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEF233C),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Create account'),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: onSignIn,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF929296)),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('I already have an account'),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
