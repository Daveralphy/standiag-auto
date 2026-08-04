// Promotional slots for the Vehicle screen's horizontal ads row — a plain
// static list, edited by hand to add/remove/reorder entries. Rendered as
// icon-and-copy cards (no stock photography) since there's no real ad
// creative to show; each is generic parts/service promo copy, not a
// specific vendor claim.

import 'package:flutter/material.dart';

class VehicleAd {
  final String title;
  final String subtitle;
  final IconData icon;

  /// Opened via url_launcher on tap, if set. Null means the card isn't
  /// tappable — just a static promo slot.
  final String? url;

  const VehicleAd({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.url,
  });
}

class VehicleAdsData {
  VehicleAdsData._();

  static const List<VehicleAd> ads = [
    VehicleAd(
      title: 'Genuine Spare Parts',
      subtitle: 'Save on brake pads, filters & more',
      icon: Icons.build_circle_outlined,
    ),
    VehicleAd(
      title: 'Engine Oil Deals',
      subtitle: 'Top-rated oil, delivered to your workshop',
      icon: Icons.local_gas_station_outlined,
    ),
    VehicleAd(
      title: 'Tyre Specials',
      subtitle: 'Save on a full set this month',
      icon: Icons.car_repair,
    ),
  ];
}
