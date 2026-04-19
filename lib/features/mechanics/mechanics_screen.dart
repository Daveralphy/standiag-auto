import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'mechanic_profile_screen.dart';

class MechanicsScreen extends StatelessWidget {
  const MechanicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchRow(),
            _buildFilterChips(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _TappableMechanicCard(
                    context: context,
                    initials: 'AO',
                    name: 'Ade Okonkwo Auto',
                    specs: ['Toyota', 'Honda', 'Electrical'],
                    rating: 4.9,
                    reviewCount: 128,
                    location: 'Lagos Island',
                    distance: '0.8 km',
                    isFeatured: true,
                    isOnline: true,
                  ),
                  const SizedBox(height: 10),
                  _TappableMechanicCard(
                    context: context,
                    initials: 'KA',
                    name: 'Kayode Auto Workshop',
                    specs: ['General Repairs', 'Diesel'],
                    rating: 4.6,
                    reviewCount: 84,
                    location: 'Victoria Island',
                    distance: '1.4 km',
                    isFeatured: false,
                    isOnline: true,
                  ),
                  const SizedBox(height: 10),
                  _TappableMechanicCard(
                    context: context,
                    initials: 'LW',
                    name: 'Lanre Workshop',
                    specs: ['Auto Electrical', 'AC Repair'],
                    rating: 4.5,
                    reviewCount: 62,
                    location: 'Surulere',
                    distance: '2.1 km',
                    isFeatured: false,
                    isOnline: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nearby Mechanics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('12 found',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: const [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: AppColors.textTertiary, size: 18),
                  SizedBox(width: 8),
                  Text('Search mechanics...',
                      style: TextStyle(fontSize: 13,
                          color: AppColors.textDisabled, fontFamily: 'Inter')),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 46, width: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.tune_rounded,
                    color: AppColors.textSecondary, size: 16),
                SizedBox(width: 6),
                Text('Filter',
                    style: TextStyle(fontSize: 13,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = ['All', 'Toyota', 'Diesel', 'Electrical', 'Verified'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(chips[i],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontFamily: 'Inter')),
          );
        },
      ),
    );
  }
}

// ── TAPPABLE MECHANIC CARD ──────────────────────────────────
class _TappableMechanicCard extends StatelessWidget {
  final BuildContext context;
  final String initials, name, location, distance;
  final List<String> specs;
  final double rating;
  final int reviewCount;
  final bool isFeatured, isOnline;

  const _TappableMechanicCard({
    required this.context,
    required this.initials,
    required this.name,
    required this.specs,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.distance,
    required this.isFeatured,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MechanicProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isFeatured ? AppColors.primaryBorder : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.vehicleCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBorder),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary, fontFamily: 'Inter')),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.advisory, shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surface, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name,
                                style: const TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Inter')),
                          ),
                          if (isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppColors.primaryBorder),
                              ),
                              child: const Text('★ FEATURED',
                                  style: TextStyle(fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      letterSpacing: 0.3, fontFamily: 'Inter')),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 5,
                        children: specs.map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDeep,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(s,
                              style: const TextStyle(fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter')),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                const SizedBox(width: 3),
                Text('$rating',
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                Text('  ($reviewCount reviews)',
                    style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
                const Spacer(),
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textTertiary, size: 13),
                const SizedBox(width: 2),
                Text('$location  •  $distance',
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textTertiary, fontFamily: 'Inter')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.whatsApp.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.whatsApp.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chat_outlined,
                              color: AppColors.whatsApp, size: 15),
                          SizedBox(width: 5),
                          Text('WA',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whatsApp, fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MechanicProfileScreen())),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Call',
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white, fontFamily: 'Inter')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
