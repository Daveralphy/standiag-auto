import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserScanScreen extends ConsumerStatefulWidget {
  const UserScanScreen({super.key});

  @override
  ConsumerState<UserScanScreen> createState() => _UserScanScreenState();
}

class _UserScanScreenState extends ConsumerState<UserScanScreen> {
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
                      Builder(builder: (ctx) {
                        final userAsync = ref.watch(userProfileProvider);
                        return GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: userAsync.when(
                            data: (user) => _Avatar(name: user?.firstName ?? '?'),
                            loading: () => const _AvatarSkeleton(),
                            error: (_, __) => const _AvatarSkeleton(),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                      const Text('Scan Vehicle', style: AppTypography.heading3),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.userScanHistory),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x08FFFFFF),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.history_rounded,
                              size: 16, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal, 0,
                        AppSpacing.pageHorizontal,
                        AppSpacing.navBarClearance),
                    child: Column(
                      children: [
                        // OBD scan icon
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0x0AE8281E),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0x1AE8281E), width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.qr_code_scanner_rounded,
                                color: AppColors.primary, size: 52),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text('OBD Diagnostic Scan',
                            style: AppTypography.heading2,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          'Connect your OBD-II adapter to your vehicle\'s\ndiagnostic port and tap scan to begin.',
                          style: AppTypography.body
                              .copyWith(color: const Color(0x59FFFFFF)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Scan button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryButtonGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              boxShadow: const [
                                BoxShadow(color: Color(0x40E8281E),
                                    blurRadius: 20, offset: Offset(0, 8)),
                              ],
                            ),
                            child: const Center(
                              child: Text('Start Scan',
                                  style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // View history
                        GestureDetector(
                          onTap: () =>
                              context.go(RouteNames.userScanHistory),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0x08FFFFFF),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border:
                                  Border.all(color: const Color(0x14FFFFFF)),
                            ),
                            child: const Center(
                              child: Text('View Scan History',
                                  style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.scan,
            userType: NavBarUserType.carOwner,
            onScanTap: () {},
            onHomeTap: () => context.go(RouteNames.userHome),
            onThirdTap: () => context.go(RouteNames.userMechanics),
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