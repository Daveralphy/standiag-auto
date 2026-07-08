import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/auth/models/mechanic_model.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../mechanics/providers/mechanics_provider.dart';

class UserMechanicsScreen extends ConsumerStatefulWidget {
  const UserMechanicsScreen({super.key});

  @override
  ConsumerState<UserMechanicsScreen> createState() =>
      _UserMechanicsScreenState();
}

class _UserMechanicsScreenState extends ConsumerState<UserMechanicsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Widget _buildUserDrawer() {
    final userAsync = ref.watch(userProfileProvider);
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userAsync.when(
                data: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${user?.username ?? ''}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 20,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: Color(0x59FFFFFF))),
                  ],
                ),
                loading: () => Container(width: 160, height: 40,
                    decoration: const BoxDecoration(color: Color(0x14FFFFFF))),
                error: (_, __) => const SizedBox(height: 40),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0x14FFFFFF), height: 32),
              _DrawerItem(icon: Icons.person_outline_rounded, label: 'My Profile',
                  onTap: () => context.push(RouteNames.userProfile)),
              _DrawerItem(icon: Icons.directions_car_outlined, label: 'My Vehicles',
                  onTap: () => context.go(RouteNames.myVehicles)),
              _DrawerItem(icon: Icons.work_outline_rounded, label: 'My Jobs',
                  onTap: () => context.go(RouteNames.myJobs)),
              _DrawerItem(icon: Icons.toll_rounded, label: 'Credits',
                  onTap: () => context.go(RouteNames.userCredits)),
              _DrawerItem(icon: Icons.settings_outlined, label: 'Settings',
                  onTap: () => context.go(RouteNames.userSettings)),
              const Spacer(),
              const Divider(color: Color(0x14FFFFFF), height: 32),
              _DrawerItem(icon: Icons.logout_rounded, label: 'Sign Out',
                  color: AppColors.primary, onTap: _signOut),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
  }


  @override
  Widget build(BuildContext context) {
    final mechanicsAsync = ref.watch(mechanicsProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildUserDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal, AppSpacing.md,
                      AppSpacing.pageHorizontal, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Builder(builder: (ctx) {
                          final userAsync = ref.watch(userProfileProvider);
                          return userAsync.when(
                            data: (user) => _Avatar(name: user?.firstName ?? '?'),
                            loading: () => const _AvatarSkeleton(),
                            error: (_, __) => const _AvatarSkeleton(),
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mechanics', style: AppTypography.heading2),
                            Text('Available nearby',
                                style: AppTypography.body),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.radiusSelector),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x08FFFFFF),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              size: 16, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: mechanicsAsync.when(
                    data: (mechanics) {
                      if (mechanics.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_off_outlined,
                                  color: Color(0x33FFFFFF), size: 48),
                              SizedBox(height: 16),
                              Text('No mechanics found nearby',
                                  style: AppTypography.heading3),
                              SizedBox(height: 8),
                              Text('Try expanding your search radius',
                                  style: AppTypography.body),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal, 0,
                            AppSpacing.pageHorizontal,
                            AppSpacing.navBarClearance),
                        itemCount: mechanics.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _MechanicListCard(mechanic: mechanics[i]),
                      );
                    },
                    loading: () => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal, 0,
                          AppSpacing.pageHorizontal,
                          AppSpacing.navBarClearance),
                      itemCount: 5,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, __) => const _MechanicCardSkeleton(),
                    ),
                    error: (_, __) => const Center(
                      child: Text('Failed to load mechanics',
                          style: AppTypography.body),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Find mechanic button
          Positioned(
            bottom: AppSpacing.navBarHeight +
                AppSpacing.navBarBottomOffset +
                12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: GestureDetector(
              onTap: () => context.go(RouteNames.radiusSelector),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40E8281E),
                        blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: const Center(
                  child: Text('Find Mechanic Near Me',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.third,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () => context.go(RouteNames.userHome),
            onThirdTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MechanicListCard extends ConsumerWidget {
  final MechanicModel mechanic;
  const _MechanicListCard({required this.mechanic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(mechanicUserProvider(mechanic.uid));

    return GestureDetector(
      onTap: () => context.go(RouteNames.mechanicProfile),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x12FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0x14E8281E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x1AE8281E)),
              ),
              child: const Center(
                child: Icon(Icons.person_outline_rounded,
                    color: AppColors.primary, size: 26),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsync.when(
                    data: (user) => Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'
                          : 'Mechanic',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w700, color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () => Container(
                        width: 120, height: 14,
                        decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(4))),
                    error: (_, __) => const Text('Mechanic',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mechanic.expertise.take(2).join(' · '),
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        color: Color(0x66FFFFFF)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.primary, size: 13),
                      const SizedBox(width: 3),
                      Text(mechanic.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(width: 10),
                      const Icon(Icons.work_outline_rounded,
                          size: 12, color: Color(0x59FFFFFF)),
                      const SizedBox(width: 3),
                      Text('${mechanic.totalJobs} jobs',
                          style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              color: Color(0x59FFFFFF))),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x14E8281E),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: const Color(0x1AE8281E)),
                  ),
                  child: const Text('Available',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: Color(0x33FFFFFF)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MechanicCardSkeleton extends StatelessWidget {
  const _MechanicCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Row(
        children: [
          Container(width: 52, height: 52,
              decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(14))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 130, height: 14,
                    decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 90, height: 11,
                    decoration: BoxDecoration(color: const Color(0x0AFFFFFF),
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: const BoxDecoration(
          gradient: AppColors.primaryButtonGradient, shape: BoxShape.circle),
      child: Center(child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
            fontWeight: FontWeight.w800, color: Colors.white),
      )),
    );
  }
}

class _AvatarSkeleton extends StatelessWidget {
  const _AvatarSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: const BoxDecoration(
        color: Color(0x14FFFFFF), shape: BoxShape.circle),
  );
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerItem({required this.icon, required this.label,
      required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 15,
              fontWeight: FontWeight.w600, color: c)),
        ]),
      ),
    );
  }
}