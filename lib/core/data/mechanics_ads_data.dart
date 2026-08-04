// Image ad banners for the Mechanics tab's auto-advancing carousel — a
// plain static list, edited by hand whenever the ad set changes. Each
// entry is a 16:9 image (see assets/images/ads/README.txt for the exact
// files expected) plus an optional destination URL opened on tap.

class MechanicsAd {
  final String imageAsset;

  /// Opened via url_launcher on tap, if set. Null means the banner isn't
  /// tappable yet — a placeholder slot waiting for a real link.
  final String? url;

  const MechanicsAd({required this.imageAsset, this.url});
}

class MechanicsAdsData {
  MechanicsAdsData._();

  static const List<MechanicsAd> ads = [
    MechanicsAd(imageAsset: 'assets/images/ads/ad_1.jpg'),
    MechanicsAd(imageAsset: 'assets/images/ads/ad_2.jpg'),
    MechanicsAd(imageAsset: 'assets/images/ads/ad_3.jpg'),
  ];
}
