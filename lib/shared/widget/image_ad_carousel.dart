// Auto-advancing image ad banner — cycles through MechanicsAdsData's
// entries on its own, sliding horizontally one after another (classic
// mobile-app promo carousel), no user interaction required to see them
// all. Still swipeable by hand; swiping just resets the auto-advance
// timer rather than fighting it.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/data/mechanics_ads_data.dart';

class ImageAdCarousel extends StatefulWidget {
  const ImageAdCarousel({super.key});

  @override
  State<ImageAdCarousel> createState() => _ImageAdCarouselState();
}

class _ImageAdCarouselState extends State<ImageAdCarousel> {
  final PageController _controller = PageController();
  Timer? _autoAdvanceTimer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (MechanicsAdsData.ads.length > 1) {
      _autoAdvanceTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _advance(),
      );
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (!mounted) return;
    final next = (_page + 1) % MechanicsAdsData.ads.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const ads = MechanicsAdsData.ads;
    if (ads.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _controller,
              itemCount: ads.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _AdBanner(ad: ads[i]),
            ),
          ),
        ),
        if (ads.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < ads.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _page ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.primary
                        : AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _AdBanner extends StatelessWidget {
  final MechanicsAd ad;
  const _AdBanner({required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ad.url == null ? null : () => launchUrl(Uri.parse(ad.url!)),
      child: Image.asset(
        ad.imageAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surface,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textDisabled,
            size: 32,
          ),
        ),
      ),
    );
  }
}
