import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MechanicsEmptyScreen extends StatelessWidget {
  const MechanicsEmptyScreen({super.key});

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
            Expanded(child: _buildEmptyState()),
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
            child: const Text('0 found',
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
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: ['All', 'Toyota', 'Diesel', 'Electrical', 'Verified']
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: e.key == 0
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: e.key == 0
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Text(e.value,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: e.key == 0
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Map pin with X
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              color: AppColors.bluetooth.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.bluetooth.withValues(alpha: 0.18), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.location_off_outlined,
                  color: AppColors.bluetooth, size: 38),
            ),
          ),
          const SizedBox(height: 24),
          const Text('No mechanics nearby.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          const SizedBox(height: 10),
          const Text(
            "We don't have any listed mechanics\nin your area yet. We're expanding fast.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                height: 1.5, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 28),
          // Expand radius button
          Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('Expand search radius to 25 km',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary, fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(height: 12),
          // Refer mechanic button
          Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Center(
              child: Text('Refer a Mechanic →',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Know a good mechanic? Add them to our\ndirectory and earn referral rewards.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary,
                height: 1.5, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }
}

