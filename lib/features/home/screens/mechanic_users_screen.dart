// Mechanic Users screen — map view showing nearby car owners.
// Nav bar active: Users. Search icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/jobs/models/job_model.dart';
import '../../../features/jobs/providers/job_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_dark_map.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../profile/screens/mechanic_drawer_screen.dart';

class MechanicUsersScreen extends ConsumerStatefulWidget {
  const MechanicUsersScreen({super.key});

  @override
  ConsumerState<MechanicUsersScreen> createState() => _MechanicUsersScreenState();
}

class _MechanicUsersScreenState extends ConsumerState<MechanicUsersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    final mechanicId = ref.watch(currentUserIdProvider);
    final requests = mechanicId == null
        ? const <JobModel>[]
        : ref.watch(pendingJobsForMechanicProvider(mechanicId)).valueOrNull ??
            const <JobModel>[];
    final markers = [
      for (final job in requests)
        if (job.carOwnerLocation != null)
          AppDarkMapMarker(
            id: job.id,
            position: LatLng(
                job.carOwnerLocation!.latitude, job.carOwnerLocation!.longitude),
            child: const AppDarkMapPin(icon: Icons.person_outline_rounded),
          ),
    ];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mapBackground,
      drawer: const MechanicDrawerScreen(),
      body: Stack(
        children: [
          AppDarkMap(
            initialCenter: const LatLng(6.5244, 3.3792),
            initialZoom: 13.2,
            markers: markers,
            radiusMeters: 2000,
          ),

          // ─── Top gradient ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF0060606), Colors.transparent],
                ),
              ),
            ),
          ),

          // ─── Header ──────────────────────────────────────────────────
          SafeArea(
            child: AppScreenHeader(
              scaffoldKey: _scaffoldKey,
              title: 'Nearby Users',
              subtitle: 'Car owners near you',
              trailingIcon: Icons.search_rounded,
              onTrailingTap: () {},
            ),
          ),

          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.mechanic,
            onScanTap: () => context.go(RouteNames.mechanicScan),
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}
