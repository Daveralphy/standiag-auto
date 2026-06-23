// Onboarding screen — three swipeable pages shown on first launch.
// Each page has a photo bleeding from the top with gradient fade,
// a title, subtitle, page dots, and next/skip/get started buttons.
// Navigates to Profile Type Picker on Get Started.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
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
      title: 'Find a Mechanic\nNearby',
      subtitle: 'Discover qualified mechanics in your area instantly.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_2.png',
      title: 'Diagnose\nYour Car',
      subtitle: 'Use our OBD scanner to get a full health report on your vehicle.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_3.png',
      title: 'Get Back\non the Road',
      subtitle: 'Connect with a mechanic, agree on a price, and get the job done.',
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
      context.go(RouteNames.profileTypePicker);
    }
  }

  void _skip() => context.go(RouteNames.profileTypePicker);

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Swipeable pages ────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
          ),

          // ─── Bottom controls overlay ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                0,
                AppSpacing.pageHorizontal,
                40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Get Started button
                  AppButton(
                    label: isLast
                        ? AppStrings.onboardingGetStarted
                        : AppStrings.onboardingNext,
                    onTap: _next,
                  ),
                  const SizedBox(height: 12),

                  // Skip button — hidden on last page
                  if (!isLast)
                    GestureDetector(
                      onTap: _skip,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppStrings.onboardingSkip,
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Onboarding Page ────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Photo bleeding from top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Stack(
            children: [
              Image.asset(
                data.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              // Gradient fade into dark background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x80000000),
                      AppColors.background,
                    ],
                    stops: [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Title and subtitle at bottom
        Positioned(
          bottom: 160,
          left: AppSpacing.pageHorizontal,
          right: AppSpacing.pageHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: AppTypography.display,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                data.subtitle,
                style: AppTypography.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}