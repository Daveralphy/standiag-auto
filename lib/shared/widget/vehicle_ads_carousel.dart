// A secondary, vertically-stacked row of promo cards for the Vehicle
// screen — full-width but visually lighter than the active vehicle card
// above it, since that card is the actual focus of the screen.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';
import '../../core/data/vehicle_ads_data.dart';

class VehicleAdsCarousel extends StatelessWidget {
  const VehicleAdsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    if (VehicleAdsData.ads.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (int i = 0; i < VehicleAdsData.ads.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _AdCard(ad: VehicleAdsData.ads[i]),
        ],
      ],
    );
  }
}

class _AdCard extends StatelessWidget {
  final VehicleAd ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ad.url == null ? null : () => launchUrl(Uri.parse(ad.url!)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: Icon(ad.icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ad.subtitle,
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
