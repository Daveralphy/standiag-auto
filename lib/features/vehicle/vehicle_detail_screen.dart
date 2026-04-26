import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/providers/vehicle_provider.dart';
import '../../core/providers/profile_provider.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final make = vehicle['make'] ?? '';
    final model = vehicle['model'] ?? '';
    final year = vehicle['year'] ?? '';
    final engineType = vehicle['engine_type'] ?? '';
    final nickname = vehicle['nickname'] as String?;
    final vin = vehicle['vin'] as String?;
    final isActive = vehicle['is_active'] == true;
    final vehicleId = vehicle['id'] as String;
    final createdAt = vehicle['created_at'] != null
        ? DateTime.parse(vehicle['created_at']).toLocal()
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // â”€â”€ Hero card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.vehicleCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isActive
                                ? AppColors.primaryBorder
                                : AppColors.border),
                        boxShadow: isActive
                            ? [BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                blurRadius: 20)]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.primaryBorder),
                            ),
                            child: const Icon(
                                Icons.directions_car_outlined,
                                color: AppColors.primary,
                                size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nickname ?? '$make $model',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Inter'),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$make $model  â€¢  $year',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.advisoryBg,
                                borderRadius:
                                    BorderRadius.circular(100),
                                border: Border.all(
                                    color: AppColors.advisoryBorder),
                              ),
                              child: const Text('ACTIVE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.advisory,
                                      letterSpacing: 0.5,
                                      fontFamily: 'Inter')),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // â”€â”€ Details â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    const Text('VEHICLE DETAILS',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                            letterSpacing: 1.5,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _row('Make', make, false),
                          _row('Model', model, false),
                          _row('Year', year, false),
                          _row('Engine Type', engineType, false),
                          if (nickname != null)
                            _row('Nickname', nickname, false),
                          if (vin != null)
                            _row('VIN', vin, false),
                          if (createdAt != null)
                            _row(
                                'Added on',
                                '${createdAt.day} ${_month(createdAt.month)} ${createdAt.year}',
                                true),
                          if (createdAt == null)
                            _row('Engine Type', engineType, true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // â”€â”€ Set Active â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (!isActive) ...[
                      _actionBtn(
                        context: context,
                        label: 'Set as Active Vehicle',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.advisory,
                        bg: AppColors.advisoryBg,
                        border: AppColors.advisoryBorder,
                        onTap: () async {
                          await VehicleService()
                              .setActiveVehicle(vehicleId);
                          ref.invalidate(activeVehicleProvider);
                          ref.invalidate(userVehiclesProvider);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    // â”€â”€ Delete â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _actionBtn(
                      context: context,
                      label: 'Delete Vehicle',
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.primary,
                      bg: AppColors.criticalBg,
                      border: AppColors.criticalBorder,
                      onTap: () => _confirmDelete(
                          context, ref, vehicleId,
                          '$make $model $year'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Vehicle Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _row(String label, String value, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFBBBBBB),
                      fontFamily: 'Inter')),
              const Spacer(),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppColors.borderSubtle),
      ],
    );
  }

  Widget _actionBtn({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
      String vehicleId, String vehicleName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Vehicle',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter')),
        content: Text(
          'Are you sure you want to delete $vehicleName? All scan history for this vehicle will also be removed. This cannot be undone.',
          style: const TextStyle(
              fontSize: 14,
              color: const Color(0xFFBBBBBB),
              height: 1.5,
              fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBBBBBB),
                    fontFamily: 'Inter')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await VehicleService().deleteVehicle(vehicleId);
              ref.invalidate(activeVehicleProvider);
              ref.invalidate(userVehiclesProvider);
              ref.invalidate(hasVehiclesProvider);
              ref.invalidate(scanCountProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[m];
  }
}

