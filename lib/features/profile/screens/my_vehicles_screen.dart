// My Vehicles screen — list of user's registered vehicles with add button.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go(RouteNames.userProfile),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text(AppStrings.vehiclesTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                GestureDetector(
                  onTap: () => context.go(RouteNames.addVehicle),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.primaryBorder)),
                    child: Text(AppStrings.vehiclesAdd,
                        style: AppTypography.captionSmall.copyWith(
                            color: AppColors.primary),
                        overflow: TextOverflow.ellipsis, maxLines: 1)),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _VehicleCard(
                  make: i == 0 ? 'Toyota' : 'Honda',
                  model: i == 0 ? 'Corolla 2019' : 'Civic 2021',
                  plate: i == 0 ? 'ABC-123-XY' : 'DEF-456-ZA',
                  fuelType: i == 0 ? 'Petrol' : 'Petrol',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String make;
  final String model;
  final String plate;
  final String fuelType;

  const _VehicleCard({
    required this.make, required this.model,
    required this.plate, required this.fuelType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.directions_car_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('$make $model',
              style: AppTypography.bodyLarge,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Tag(plate)),
          const SizedBox(width: 6),
          Expanded(child: _Tag(fuelType)),
        ]),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border)),
      child: Text(label,
          style: AppTypography.micro,
          overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}