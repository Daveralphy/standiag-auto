import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/providers/vehicle_provider.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final activeVehicleAsync = ref.watch(activeVehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header with Add button ──────────────────
            _buildHeader(context, ref),
            // ── Vehicle List ─────────────────────────────
            Expanded(
              child: vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return activeVehicleAsync.when(
                    data: (activeVehicle) =>
                        _buildVehicleList(context, ref, vehicles, activeVehicle),
                    loading: () => _buildVehicleList(context, ref, vehicles, null),
                    error: (_, __) => _buildVehicleList(context, ref, vehicles, null),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, __) => Center(
                  child: Text(
                    'Failed to load vehicles',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary, size: 28),
          ),
          const Text(
            'My Vehicles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AddVehicleScreen()))
                .then((_) {
              ref.invalidate(userVehiclesProvider);
              ref.invalidate(activeVehicleProvider);
            }),
            child: const Icon(Icons.add_rounded,
                color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No vehicles added yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first vehicle to get started with diagnostics',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> vehicles,
    Map<String, dynamic>? activeVehicle,
  ) {
    final activeId = activeVehicle?['id'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          ...vehicles.asMap().entries.map((entry) {
            final index = entry.key;
            final vehicle = entry.value;
            final isActive = vehicle['id'] == activeId;
            final isLast = index == vehicles.length - 1;

            return Column(
              children: [
                _buildVehicleCard(context, vehicle, isActive, ref),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    Map<String, dynamic> vehicle,
    bool isActive,
    WidgetRef ref,
  ) {
    final make = vehicle['make'] ?? '';
    final model = vehicle['model'] ?? '';
    final year = vehicle['year'] ?? '';
    final nickname = vehicle['nickname'] as String?;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: vehicle)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.vehicleCard,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: isActive ? AppColors.primaryBorder : AppColors.border,
          ),
          boxShadow: isActive
              ? [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 20,
                )]
              : null,
        ),
        child: Row(
          children: [
            // Vehicle Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            // Vehicle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nickname ?? '$make $model',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$make $model • $year',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Active Badge
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.advisoryBg,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.advisoryBorder),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.advisory,
                    letterSpacing: 0.5,
                    fontFamily: 'Inter',
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
