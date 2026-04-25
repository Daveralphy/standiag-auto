import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/vehicle_provider.dart';
import '../../core/services/auth_service.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/upgrade_screen.dart';
import '../vehicle/add_vehicle_screen.dart';
import '../vehicle/vehicle_detail_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final vehiclesAsync = ref.watch(userVehiclesProvider);
    final scanCountAsync = ref.watch(scanCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 24),
              profileAsync.when(
                data: (profile) => _buildAvatar(profile),
                loading: () => _buildAvatarSkeleton(),
                error: (_, __) => _buildAvatar(null),
              ),
              const SizedBox(height: 20),
_buildProCard(context),
              const SizedBox(height: 24),
              vehiclesAsync.when(
                data: (vehicles) =>
                    _buildVehiclesSection(context, ref, vehicles),
                loading: () =>
                    _buildVehiclesSection(context, ref, null),
                error: (_, __) =>
                    _buildVehiclesSection(context, ref, []),
              ),
              const SizedBox(height: 24),
              _buildAccountSection(
                context,
                ref,
                scanCount: scanCountAsync.value ?? 0,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('My Profile',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter')),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(Map<String, dynamic>? profile) {
    final firstName = profile?['first_name'] ?? '';
    final lastName = profile?['last_name'] ?? '';
    final username = profile?['username'] ?? '';
    final createdAt = profile?['created_at'] != null
        ? DateTime.parse(profile!['created_at'])
        : null;

    final initials = _initials(firstName, lastName);
    final joinStr = createdAt != null
        ? 'Member since ${_monthName(createdAt.month)} ${createdAt.year}'
        : 'Member since recently';
    final fullName = firstName.isNotEmpty || lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'StanDiag User';

    return Center(
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.vehicleCard,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryBorder, width: 2),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(height: 12),
          Text(fullName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          if (username.isNotEmpty)
            Text('@$username',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(joinStr,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildAvatarSkeleton() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 12),
          Container(
              width: 140, height: 18,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(
              width: 80, height: 13,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }


  Widget _buildProCard(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.vehicleCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to StanDiag Pro',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  SizedBox(height: 4),
                  Wrap(spacing: 6, children: [
                    _ProChip(label: 'Unlimited scans'),
                    _ProChip(label: 'Full AI reports'),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Upgrade →',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Inter')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesSection(BuildContext context, WidgetRef ref,
      List<Map<String, dynamic>>? vehicles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MY VEHICLES',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                    fontFamily: 'Inter')),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => const AddVehicleScreen()))
                  .then((_) {
                ref.invalidate(userVehiclesProvider);
                ref.invalidate(activeVehicleProvider);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: const Text('+ Add',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Inter')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (vehicles == null)
          Column(children: [
            _skeleton(), const SizedBox(height: 8), _skeleton(),
          ])
        else if (vehicles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('No vehicles added yet.',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
          )
        else
          ...vehicles.asMap().entries.map((e) {
            final v = e.value;
            final isLast = e.key == vehicles.length - 1;
            return Column(children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) =>
                            VehicleDetailScreen(vehicle: v)))
                    .then((_) {
                  ref.invalidate(userVehiclesProvider);
                  ref.invalidate(activeVehicleProvider);
                }),
                child: _VehicleRow(
                  name:
                      '${v['make']} ${v['model']}  •  ${v['year']}',
                  detail:
                      '${v['engine_type']}${v['nickname'] != null ? '  •  ${v['nickname']}' : ''}',
                  isActive: v['is_active'] == true,
                ),
              ),
              if (!isLast) const SizedBox(height: 8),
            ]);
          }),
      ],
    );
  }

  Widget _skeleton() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref,
      {required int scanCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACCOUNT SETTINGS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        _SettingsRow(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          trailing: '',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen())),
        ),
        const SizedBox(height: 8),
        _SettingsRow(
          icon: Icons.logout_rounded,
          label: 'Sign Out',
          trailing: '',
          isDestructive: true,
          onTap: () async {
            await AuthService().signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  String _initials(String firstName, String lastName) {
    final f =
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l =
        lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : 'SD';
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November',
      'December'
    ];
    return months[month];
  }
}

// ── SUPPORTING WIDGETS ────────────────────────────────────────

class _ProChip extends StatelessWidget {
  final String label;
  const _ProChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontFamily: 'Inter')),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final String name, detail;
  final bool isActive;

  const _VehicleRow({
    required this.name,
    required this.detail,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive
                ? AppColors.primaryBorder
                : AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 3),
                Text(detail,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.advisoryBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.advisoryBorder),
              ),
              child: const Text('ACTIVE',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.advisory,
                      letterSpacing: 0.5,
                      fontFamily: 'Inter')),
            )
          else
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 18),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label, trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.primary : AppColors.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDestructive
                  ? AppColors.primaryBorder
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontFamily: 'Inter')),
            ),
            if (trailing.isNotEmpty)
              Text(trailing,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            const SizedBox(width: 6),
            if (!isDestructive)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}






