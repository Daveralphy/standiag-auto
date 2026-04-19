import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifs = true;
  bool _maintenanceAlerts = true;
  bool _scanReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _SectionLabel(label: 'NOTIFICATIONS'),
                  const SizedBox(height: 10),
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    label: 'Push Notifications',
                    value: _pushNotifs,
                    onChanged: (v) => setState(() => _pushNotifs = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.build_outlined,
                    label: 'Maintenance Reminders',
                    value: _maintenanceAlerts,
                    onChanged: (v) => setState(() => _maintenanceAlerts = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.wifi_tethering_outlined,
                    label: 'Weekly Scan Reminders',
                    value: _scanReminders,
                    onChanged: (v) => setState(() => _scanReminders = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'ACCOUNT'),
                  const SizedBox(height: 10),
                  _NavRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    subtitle: 'Raphael Daveal  @daveralphy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'APP'),
                  const SizedBox(height: 10),
                  _NavRow(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: Icons.article_outlined,
                    label: 'Terms of Service',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
                    trailing: 'v1.0.0 (build 42)',
                    showChevron: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'DANGER ZONE', isRed: true),
                  const SizedBox(height: 10),
                  _NavRow(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    isDestructive: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete Account',
                    trailing: 'Permanent',
                    isDestructive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Text('Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRed;
  const _SectionLabel({required this.label, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5,
            color: isRed ? AppColors.primary : AppColors.textTertiary,
            fontFamily: 'Inter'));
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.icon, required this.label,
      required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14,
                    color: AppColors.textPrimary, fontFamily: 'Inter')),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.advisory,
            inactiveTrackColor: AppColors.border,
            inactiveThumbColor: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailing;
  final bool isDestructive;
  final bool showChevron;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon, required this.label, required this.onTap,
    this.subtitle, this.trailing, this.isDestructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.primary : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDestructive ? AppColors.primaryBorder : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color, fontFamily: 'Inter')),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(fontSize: 11,
                            color: AppColors.textTertiary, fontFamily: 'Inter')),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textTertiary, fontFamily: 'Inter')),
            if (showChevron) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
