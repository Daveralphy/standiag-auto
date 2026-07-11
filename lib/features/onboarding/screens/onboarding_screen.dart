// Onboarding screen — 3 swipeable pages.
// Photo bleeds from top (65% of screen height) with gradient fade.
// Dots + Skip sit at the top of the content area.
// Headline, subline, and button at the bottom.
// Screen 3 shows "Have an account? Sign in" below the button.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/images/onboarding_1.png',
      headline: 'Help is one',
      accent: 'tap away.',
      subline:
          'Describe your issue and get matched with a verified mechanic nearby in seconds.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_2.png',
      headline: 'Your mechanic',
      accent: 'is near.',
      subline:
          'See verified mechanics around you, ratings, and real-time distance. Pick who you trust.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_3.png',
      headline: 'Fixed. Rated.',
      accent: 'Done.',
      subline:
          'Pay securely in-app and rate your mechanic. Quality you can trust, every time.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(RouteNames.profileTypePicker);
    }
  }

  Future<void> _completeOnboarding(String route) async {
    await CacheManager.instance.write(
      box: CacheKeys.settingsBox,
      key: CacheKeys.onboardingSeen,
      value: true,
    );
    if (!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentPage == _pages.length - 1;
    final data = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Swipeable photo layer ─────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _PhotoLayer(image: _pages[i].image),
          ),

          // ─── Content layer ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top nav — dots truly centered, Skip absolutely positioned
                // on top so its width can never throw off the dots' centering.
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                  child: SizedBox(
                    height: 24,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (i) {
                            final bool active = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 28 : 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    : const Color(0x38FFFFFF),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.9),
                                          blurRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.35),
                                          blurRadius: 22,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                        if (!isLast)
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _completeOnboarding(RouteNames.login),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 60),
                                child: Text(
                                  'Skip',
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0x99FFFFFF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Spacer pushes bottom content down
                const Spacer(),

                // Bottom — headline, subline, button, sign in
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 76),
                  child: Column(
                    children: [
                      // Headline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 33,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -1.4,
                          ),
                          children: [
                            TextSpan(text: '${data.headline}\n'),
                            TextSpan(
                              text: data.accent,
                              style: const TextStyle(
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subline
                      Text(
                        data.subline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0x99FFFFFF),
                          height: 1.55,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),

                      // Primary button
                      GestureDetector(
                        onTap: _next,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFF03328), Color(0xFFC41F16)],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x99820F0A),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Color(0x40C81E14),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Color(0x1AE8281E),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                           child: Text(
                             isLast ? 'Get Started' : 'Next',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),

                      // Sign in link — screen 3 only
                      if (isLast)
                        GestureDetector(
                          onTap: () => context.go(RouteNames.login),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0x59FFFFFF),
                                  letterSpacing: -0.1,
                                ),
                                children: [
                                  TextSpan(text: 'Have an account? '),
                                  TextSpan(
                                    text: 'Sign in',
                                    style:
                                        TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Photo Layer ─────────────────────────────────────────────────────────────

class _PhotoLayer extends StatelessWidget {
  final String image;
  const _PhotoLayer({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Stack(
            children: [
              Image.asset(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              // Bottom fade — blends the photo into the dark background.
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x73000000),
                      Color(0xE0000000),
                      AppColors.background,
                    ],
                    stops: [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),
              // Top scrim — keeps the status bar legible over bright photos.
              Container(
                height: MediaQuery.of(context).size.height * 0.65 * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x73000000),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _OnboardingData {
  final String image;
  final String headline;
  final String accent;
  final String subline;
  const _OnboardingData({
    required this.image,
    required this.headline,
    required this.accent,
    required this.subline,
  });
}