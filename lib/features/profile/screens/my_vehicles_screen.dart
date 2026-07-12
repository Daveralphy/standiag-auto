// My Vehicles screen — list of user's registered vehicles with add button.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class MyVehiclesScreen extends ConsumerStatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  ConsumerState<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends ConsumerState<MyVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      ref.read(profileProvider.notifier).fetchVehicles(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

    final state = ref.watch(profileProvider);

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
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.userProfile);
                    }
                  },
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
                  onTap: () => context.push(RouteNames.addVehicle),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.primaryBorder)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(AppStrings.vehiclesAdd,
                            style: AppTypography.captionSmall.copyWith(
                                color: AppColors.primary),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: state.isLoading && state.vehicles.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, __) => const VehicleCardSkeleton(),
                    )
                  : state.vehicles.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_car_outlined,
                                    color: Color(0x33FFFFFF), size: 48),
                                const SizedBox(height: 16),
                                const Text('No vehicles yet',
                                    style: AppTypography.heading3),
                                const SizedBox(height: 8),
                                const Text(
                                    'Add your first vehicle to start diagnosing it with OBD.',
                                    style: AppTypography.body,
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () =>
                                      context.push(RouteNames.addVehicle),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient:
                                          AppColors.primaryButtonGradient,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.full),
                                    ),
                                    child: const Text('Add a Vehicle',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          itemCount: state.vehicles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _VehicleCard(
                            name:
                                '${state.vehicles[i].make} ${state.vehicles[i].model}',
                            year: state.vehicles[i].year,
                            meta: [
                              state.vehicles[i].type,
                              state.vehicles[i].colour,
                              state.vehicles[i].fuelType,
                            ].where((s) => s.isNotEmpty).join(' · '),
                            plate: state.vehicles[i].plateNumber,
                            onEdit: () => context.push(
                                RouteNames.editVehicle,
                                extra: state.vehicles[i].id),
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
  final String name;
  final String year;
  final String meta;
  final String plate;
  final VoidCallback onEdit;

  const _VehicleCard({
    required this.name,
    required this.year,
    required this.meta,
    required this.plate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                if (year.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(year,
                      style: AppTypography.captionLarge
                          .copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(meta,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
                if (plate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(plate,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined,
                color: AppColors.textMuted, size: 16),
          ),
        ],
      ),
    );
  }
}