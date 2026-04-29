import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/vehicle_provider.dart';
import '../../core/services/auth_service.dart';
import '../notifications/notifications_screen.dart';
import '../subscription/upgrade_screen.dart';
import '../vehicle/add_vehicle_screen.dart';
import '../auth/login_screen.dart';
import 'profile_detail_screen.dart';
import 'account_management_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final activeVehicleAsync = ref.watch(activeVehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Full-width Header ────────────────────────
            AppHeader(
              title: 'My Profile',
              subtitle: _formattedDate(),
              action: const NotifBell(),
              onActionTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            // ── Scrollable Content ───────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Profile Summary Card ──────────────────────
                    profileAsync.when(
                      data: (profile) => _buildSummaryCard(context, profile, activeVehicleAsync),
                      loading: () => _buildSummarySkeleton(),
                      error: (_, __) => _buildSummaryCard(context, null, activeVehicleAsync),
                    ),
                    const SizedBox(height: 24),

                    // ── Menu List ─────────────────────────────────
                    _buildMenuSection(context, ref, vehiclesAsync),
                    const SizedBox(height: 32),

                    // ── Logout Button ─────────────────────────────
                    _buildLogoutButton(context, ref),
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

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _initials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final result = '$f$l';
    return result.isNotEmpty ? result : 'SD';
  }

  Widget _buildSummaryCard(
    BuildContext context,
    Map<String, dynamic>? profile,
    AsyncValue<Map<String, dynamic>?> activeVehicleAsync,
  ) {
    final firstName = profile?['first_name'] as String? ?? '';
    final lastName = profile?['last_name'] as String? ?? '';
    final username = profile?['username'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    final initials = _initials(firstName, lastName);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar - increased size
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.vehicleCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder, width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'StanDiag User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (username.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                activeVehicleAsync.when(
                  data: (v) => Text(
                    v != null
                        ? '${v['make']} ${v['model']} ${v['year']}'
                        : 'No vehicle added',
                    style: TextStyle(
                      fontSize: 13,
                      color: v != null ? AppColors.primary : AppColors.textTertiary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ],
      ),
    );
  }

  Widget _buildSummarySkeleton() {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Map<String, dynamic>>> vehiclesAsync,
  ) {
    return Column(
      children: [
        _MenuItem(
          icon: Icons.person_outline_rounded,
          label: 'Profile',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileDetailScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Icons.directions_car_outlined,
          label: 'Vehicles',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddVehicleScreen()))
              .then((_) {
            ref.invalidate(userVehiclesProvider);
            ref.invalidate(activeVehicleProvider);
          }),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Icons.workspace_premium_outlined,
          label: 'Subscription',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UpgradeScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          icon: Icons.shield_outlined,
          label: 'Account Management',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AccountManagementScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _confirmSignOut(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.criticalBg,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.criticalBorder),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await AuthService().signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      AppToast.error(context, 'Failed to sign out. Please try again.');
    }
  }
}

// ── MENU ITEM ─────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
