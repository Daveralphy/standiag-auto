import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_header.dart';
import '../../core/providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            AppSecondaryHeader(
              title: 'Profile',
              action: const Icon(Icons.edit_outlined, color: AppColors.textPrimary, size: 18),
              onActionTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))
                  .then((_) => ref.invalidate(profileProvider)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: profileAsync.when(
                data: (profile) => _buildContent(context, profile),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                ),
                error: (_, __) => _buildContent(context, null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic>? profile) {
    final firstName = profile?['first_name'] as String? ?? '';
    final lastName = profile?['last_name'] as String? ?? '';
    final username = profile?['username'] as String? ?? '';
    final phone = profile?['phone'] as String? ?? '';
    final email = profile?['email'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    final initials = _initials(firstName, lastName);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.vehicleCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder, width: 2),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppColors.primary, fontFamily: 'Inter',
                  )),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName.isNotEmpty ? fullName : 'StanDiag User',
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 28),

          // Personal section
          _sectionLabel('PERSONAL'),
          const SizedBox(height: 8),
          _InfoCard(rows: [
            _InfoRow(label: 'First Name', value: firstName.isNotEmpty ? firstName : '—'),
            _InfoRow(label: 'Last Name', value: lastName.isNotEmpty ? lastName : '—'),
            _InfoRow(label: 'Username', value: username.isNotEmpty ? '@$username' : '—'),
            _InfoRow(label: 'Phone', value: phone.isNotEmpty ? phone : '—', isLast: true),
          ]),
          const SizedBox(height: 20),

          // Security section
          _sectionLabel('SECURITY'),
          const SizedBox(height: 8),
          _SecurityCard(
            email: email,
            onChangeEmail: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChangeEmailScreen(currentEmail: email)),
            ),
            onChangePassword: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppTypography.overline),
    );
  }

  String _initials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final r = '$f$l';
    return r.isNotEmpty ? r : 'SD';
  }
}

// ── INFO CARD WITH DIVIDERS ───────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.map((row) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Text(row.label,
                        style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter',
                        )),
                    const Spacer(),
                    Text(row.value,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary, fontFamily: 'Inter',
                        )),
                  ],
                ),
              ),
              if (!row.isLast)
                const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.label, required this.value, this.isLast = false});
}

// ── SECURITY CARD ─────────────────────────────────────────────
class _SecurityCard extends StatelessWidget {
  final String email;
  final VoidCallback onChangeEmail;
  final VoidCallback onChangePassword;

  const _SecurityCard({
    required this.email,
    required this.onChangeEmail,
    required this.onChangePassword,
  });

  String _maskEmail(String e) {
    if (!e.contains('@')) return e;
    final parts = e.split('@');
    final name = parts[0];
    final masked = name.length > 2
        ? '${name[0]}${'•' * (name.length - 2)}${name[name.length - 1]}'
        : name;
    return '$masked@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('Email',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _maskEmail(email),
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary, fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onChangeEmail,
                  child: const Text('Change',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.primary, fontFamily: 'Inter',
                      )),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('Password',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter')),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '••••••••',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary, fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onChangePassword,
                  child: const Text('Change',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.primary, fontFamily: 'Inter',
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
