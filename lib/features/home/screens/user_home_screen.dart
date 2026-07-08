import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/models/mechanic_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../mechanics/providers/mechanics_provider.dart';

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Widget _buildUserDrawer() {
    final userAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(currentUserProvider);
    final drawerName = _resolvedDisplayName(
      userAsync.valueOrNull,
      authUser,
    );
    final drawerEmail = userAsync.valueOrNull?.email.isNotEmpty == true
        ? userAsync.valueOrNull!.email
        : (authUser?.email ?? '');
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
                      '@${user?.username.isNotEmpty == true ? user!.username : drawerName.toLowerCase()}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 20,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(drawerEmail,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: Color(0x59FFFFFF))),
                  ],
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${drawerName.toLowerCase()}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 20,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(drawerEmail,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: Color(0x59FFFFFF))),
                  ],
                ),
                error: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${drawerName.toLowerCase()}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 20,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(drawerEmail,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: Color(0x59FFFFFF))),
                  ],
                ),
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
    final userAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(currentUserProvider);
    final mechanicsAsync = ref.watch(mechanicsProvider);

    final displayName = userAsync.when(
      data: (user) => _resolvedDisplayName(user, authUser),
      loading: () => authUser?.displayName ?? authUser?.email?.split('@').first ?? 'there',
      error: (_, __) => authUser?.displayName ?? authUser?.email?.split('@').first ?? 'there',
    );
    final avatarLabel = _avatarLabel(displayName);

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
                      // Avatar — opens drawer
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: userAsync.when(
                          data: (_) => _Avatar(name: avatarLabel),
                          loading: () => const _AvatarSkeleton(),
                          error: (_, __) => _Avatar(name: avatarLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: userAsync.when(
                          data: (user) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $displayName 👋',
                                style: AppTypography.heading2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const Text('Your Dashboard',
                                  style: AppTypography.body,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          loading: () => const _GreetingSkeleton(),
                          error: (_, __) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $displayName 👋',
                                style: AppTypography.heading2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const Text('Your Dashboard',
                                  style: AppTypography.body,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                      // Bell
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: AppSpacing.iconButtonSize,
                          height: AppSpacing.iconButtonSize,
                          decoration: BoxDecoration(
                            color: const Color(0x08FFFFFF),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              size: 16, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.navBarClearance),
                    children: [
                        // ─── Diagnose card ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: GestureDetector(
                            onTap: () => context.go(RouteNames.userScan),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryButtonGradient,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x33E8281E),
                                      blurRadius: 20, offset: Offset(0, 8)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.qr_code_scanner_rounded,
                                      color: Colors.white, size: 28),
                                  const SizedBox(height: 12),
                                  const Text("Let's Diagnose",
                                      style: AppTypography.heading2),
                                  const Text('Your Vehicle',
                                      style: AppTypography.heading2),
                                  const SizedBox(height: 8),
                                  Text('Tap to scan your car with OBD',
                                      style: AppTypography.bodySmall
                                          .copyWith(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Quick Actions ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Row(
                            children: [
                              _QuickAction(
                                  icon: Icons.history_rounded,
                                  label: 'Scan\nHistory',
                                  onTap: () => context
                                      .go(RouteNames.userScanHistory)),
                              const SizedBox(width: 10),
                              _QuickAction(
                                  icon: Icons.directions_car_outlined,
                                  label: 'My\nVehicles',
                                  onTap: () =>
                                      context.go(RouteNames.myVehicles)),
                              const SizedBox(width: 10),
                              _QuickAction(
                                  icon: Icons.work_outline_rounded,
                                  label: 'My\nJobs',
                                  onTap: () =>
                                      context.go(RouteNames.myJobs)),
                              const SizedBox(width: 10),
                              _QuickAction(
                                  icon: Icons.toll_rounded,
                                  label: 'My\nCredits',
                                  onTap: () =>
                                      context.go(RouteNames.userCredits)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Nearby Mechanics ────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Great Mechanics',
                                        style: AppTypography.heading3),
                                    Text('Standby Nearby',
                                        style: AppTypography.body),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go(RouteNames.userMechanics),
                                child: Text('See all',
                                    style: AppTypography.bodySmall
                                        .copyWith(color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        mechanicsAsync.when(
                          data: (mechanics) {
                            if (mechanics.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.pageHorizontal),
                                child: Text('No mechanics available nearby.',
                                    style: AppTypography.body),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.pageHorizontal),
                              child: Column(
                                children: mechanics
                                    .take(3)
                                    .map((m) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10),
                                          child: _MechanicCard(mechanic: m),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                          loading: () => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.pageHorizontal),
                            child: Column(
                              children: List.generate(
                                3,
                                (_) => const Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: _MechanicCardSkeleton(),
                                ),
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.home,
            userType: NavBarUserType.carOwner,
            onScanTap: () => context.go(RouteNames.userScan),
            onHomeTap: () {},
            onThirdTap: () => context.go(RouteNames.userMechanics),
          ),
        ],
      ),
    );
  }

  String _resolvedDisplayName(UserModel? user, User? authUser) {
    final firstName = user?.firstName.trim() ?? '';
    if (firstName.isNotEmpty) {
      return firstName;
    }

    final username = user?.username.trim() ?? '';
    if (username.isNotEmpty) {
      return username;
    }

    final displayName = authUser?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final emailPrefix = authUser?.email?.split('@').first.trim() ?? '';
    if (emailPrefix.isNotEmpty) {
      return emailPrefix;
    }

    return 'there';
  }

  String _avatarLabel(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty || trimmed == 'there') {
      return '?';
    }
    return trimmed[0].toUpperCase();
  }

}

// ─── Widgets ───────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AvatarSkeleton extends StatelessWidget {
  const _AvatarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: const BoxDecoration(
        color: Color(0x14FFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w600, color: c,
                )),
          ],
        ),
      ),
    );
  }
}

class _MechanicCard extends ConsumerWidget {
  final MechanicModel mechanic;
  const _MechanicCard({required this.mechanic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(mechanicUserProvider(mechanic.uid));
    return GestureDetector(
      onTap: () => context.go(RouteNames.mechanicProfile),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x12FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0x14E8281E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x1AE8281E)),
              ),
              child: const Center(
                child: Icon(Icons.person_outline_rounded,
                    color: AppColors.primary, size: 24),
              ),
            ),
            const SizedBox(width: 12),
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
                        width: 100, height: 14,
                        decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(4))),
                    error: (_, __) => const Text('Mechanic',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mechanic.expertise.isNotEmpty
                        ? mechanic.expertise.first
                        : 'General',
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        color: Color(0x80FFFFFF)),
                  ),
                  const SizedBox(height: 6),
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
                      const SizedBox(width: 8),
                      Text('${mechanic.totalJobs} jobs',
                          style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              color: Color(0x59FFFFFF))),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0x33FFFFFF)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x12FFFFFF)),
          ),
          child: Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x14E8281E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600, color: Colors.white,
                    height: 1.3,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 140, height: 20,
            decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 6),
        Container(width: 100, height: 14,
            decoration: BoxDecoration(color: const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(6))),
      ],
    );
  }
}

class _MechanicCardSkeleton extends StatelessWidget {
  const _MechanicCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 14,
                    decoration: BoxDecoration(color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 80, height: 11,
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