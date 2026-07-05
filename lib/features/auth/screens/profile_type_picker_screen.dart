// Profile Type Picker — photo bleeds top 180px, "Who are you?" headline,
// two selectable cards (Car Owner / Mechanic), Continue button at bottom.
// Back button top-left navigates to login.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

enum _ProfileType { carOwner, mechanic }

class ProfileTypePickerScreen extends StatefulWidget {
  const ProfileTypePickerScreen({super.key});

  @override
  State<ProfileTypePickerScreen> createState() =>
      _ProfileTypePickerScreenState();
}

class _ProfileTypePickerScreenState extends State<ProfileTypePickerScreen> {
  _ProfileType _selected = _ProfileType.carOwner;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  void _continue() {
    if (_selected == _ProfileType.carOwner) {
      context.go(RouteNames.userSignupStepOne);
    } else {
      context.go(RouteNames.mechanicSignupStepOne);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Photo bleed top ─────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 180,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/onboarding_1.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x000A0A0A),
                        Color(0x800A0A0A),
                        AppColors.background,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Full layout ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button — top left
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: GestureDetector(
                    onTap: () => context.go(RouteNames.login),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0x12FFFFFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x14FFFFFF)),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Bottom content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Headline
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(text: 'Who are ',
                                style: TextStyle(color: Colors.white)),
                            TextSpan(text: 'you?',
                                style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose your account type to get started',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: Color(0x59FFFFFF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Car Owner card
                      _TypeCard(
                        title: 'Car Owner',
                        subtitle: 'I need a mechanic',
                        selected: _selected == _ProfileType.carOwner,
                        onTap: () => setState(
                            () => _selected = _ProfileType.carOwner),
                      ),
                      const SizedBox(height: 12),

                      // Mechanic card
                      _TypeCard(
                        title: 'Mechanic',
                        subtitle: 'I fix cars',
                        selected: _selected == _ProfileType.mechanic,
                        onTap: () => setState(
                            () => _selected = _ProfileType.mechanic),
                      ),
                      const SizedBox(height: 24),

                      // Continue button
                      GestureDetector(
                        onTap: _continue,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF03328),
                                Color(0xFFC41F16)
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x38E8281E),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('Continue',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                )),
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

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0x0FE8281E)
              : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0x14FFFFFF),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : const Color(0x80FFFFFF),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: selected
                          ? const Color(0x80FFFFFF)
                          : const Color(0x40FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : const Color(0x26FFFFFF),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}