import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/vehicle_provider.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVehicleAsync = ref.watch(activeVehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            activeVehicleAsync.when(
              data: (v) => _buildHeader(context, v),
              loading: () => _buildHeader(context, null),
              error: (_, __) => _buildHeader(context, null),
            ),
            Expanded(
              child: activeVehicleAsync.when(
                data: (v) => v != null
                    ? _buildComingSoon(context, v)
                    : _buildNoVehicle(context),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                ),
                error: (_, __) => _buildNoVehicle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Map<String, dynamic>? vehicle) {
    final vehicleLabel = vehicle != null
        ? '${vehicle['make']} ${vehicle['model']} ${vehicle['year']}'
        : 'No vehicle selected';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Maintenance',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                Text(
                  '$vehicleLabel  •  Keep your car healthy',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter'),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicle(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                color: AppColors.textTertiary, size: 52),
            const SizedBox(height: 20),
            const Text('No vehicle added',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter')),
            const SizedBox(height: 8),
            const Text(
              'Add your vehicle first to get personalised maintenance reminders based on your car type and usage.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontFamily: 'Inter'),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Add a Vehicle',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Inter')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoon(
      BuildContext context, Map<String, dynamic> vehicle) {
    final vehicleName =
        '${vehicle['make']} ${vehicle['model']} ${vehicle['year']}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Vehicle context card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.vehicleCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryBorder),
                  ),
                  child: const Icon(
                      Icons.directions_car_outlined,
                      color: AppColors.primary,
                      size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(vehicleName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                      const SizedBox(height: 2),
                      Text(
                        vehicle['engine_type'] ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Coming soon illustration
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryBorder, width: 2),
            ),
            child: const Icon(Icons.build_circle_outlined,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Maintenance Reminders',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 12),
          const Text(
            'After your first diagnostic scan, StanDiag will automatically suggest maintenance tasks based on your vehicle type, mileage, and scan results.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
                fontFamily: 'Inter'),
          ),
          const SizedBox(height: 28),
          // What to expect
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WHAT TO EXPECT',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                        fontFamily: 'Inter')),
                const SizedBox(height: 12),
                _ExpectRow(
                  icon: Icons.oil_barrel_outlined,
                  color: AppColors.moderate,
                  title: 'Oil & Filter Reminders',
                  subtitle:
                      'Based on your engine type and usage',
                ),
                const SizedBox(height: 10),
                _ExpectRow(
                  icon: Icons.tire_repair_outlined,
                  color: AppColors.primary,
                  title: 'Tyre & Brake Checks',
                  subtitle: 'Scheduled based on mileage',
                ),
                const SizedBox(height: 10),
                _ExpectRow(
                  icon: Icons.electric_bolt_outlined,
                  color: AppColors.advisory,
                  title: 'Battery & Spark Plugs',
                  subtitle:
                      'Time-based reminders per manufacturer specs',
                ),
                const SizedBox(height: 10),
                _ExpectRow(
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.advisory,
                  title: 'Mark as Done',
                  subtitle:
                      'Log completed tasks to reset timers',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // CTA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'Run your first scan to unlock\npersonalised maintenance reminders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Text('Go to Scan →',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ExpectRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;

  const _ExpectRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter')),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
      ],
    );
  }
}
