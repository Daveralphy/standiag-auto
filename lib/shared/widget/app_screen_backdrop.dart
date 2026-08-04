// The dim photo-bleed backdrop used behind the login and signup screens —
// a background image fading into the app's dark background via a
// top-to-bottom gradient, so it reads as atmosphere behind the content
// rather than competing with it for contrast. Pulled out here so the same
// treatment can sit behind any screen's content, not just auth ones.

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppScreenBackdrop extends StatelessWidget {
  final String asset;

  /// How much of the screen's height the photo occupies before fading out.
  final double heightFraction;

  const AppScreenBackdrop({
    super.key,
    this.asset = 'assets/images/onboarding_1.png',
    this.heightFraction = 0.30,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * heightFraction,
      child: Stack(
        children: [
          Image.asset(
            asset,
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
                  Color(0x80000000),
                  Colors.transparent,
                  Color(0xA60A0A0A),
                  AppColors.background,
                ],
                stops: [0.0, 0.0, 0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
