import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifs = true;
  bool _maintenanceAlerts = true;
  bool _scanReminders = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

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
                  // ── Account ──────────────────────────────
                  const _SectionLabel(label: 'ACCOUNT'),
                  const SizedBox(height: 10),
                  profileAsync.when(
                    data: (profile) => _NavRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      subtitle: profile != null
                          ? '${profile['first_name']} ${profile['last_name']}'
                              .trim()
                          : '',
                      onTap: () =>
                          _showEditProfile(context, profile),
                    ),
                    loading: () => _NavRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    error: (_, __) => _NavRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () =>
                        _showChangePassword(context),
                  ),
                  const SizedBox(height: 24),

                  // ── Notifications ─────────────────────────
                  const _SectionLabel(label: 'NOTIFICATIONS'),
                  const SizedBox(height: 10),
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    label: 'Push Notifications',
                    value: _pushNotifs,
                    onChanged: (v) =>
                        setState(() => _pushNotifs = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.build_outlined,
                    label: 'Maintenance Reminders',
                    value: _maintenanceAlerts,
                    onChanged: (v) =>
                        setState(() => _maintenanceAlerts = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.wifi_tethering_outlined,
                    label: 'Weekly Scan Reminders',
                    value: _scanReminders,
                    onChanged: (v) =>
                        setState(() => _scanReminders = v),
                  ),
                  const SizedBox(height: 24),

                  // ── App ───────────────────────────────────
                  const _SectionLabel(label: 'APP'),
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
                    trailing: 'v1.0.0',
                    showChevron: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // ── Danger Zone ───────────────────────────
                  const _SectionLabel(
                      label: 'DANGER ZONE', isRed: true),
                  const SizedBox(height: 10),
                  _NavRow(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    isDestructive: true,
                    onTap: () => _confirmSignOut(context),
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: Icons.delete_forever_rounded,
                    label: 'Delete Account',
                    trailing: 'Permanent',
                    isDestructive: true,
                    showChevron: false,
                    onTap: () => _confirmDeleteAccount(context),
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  // ── Edit Profile Sheet ───────────────────────────────────
  void _showEditProfile(
      BuildContext context, Map<String, dynamic>? profile) {
    final firstCtrl = TextEditingController(
        text: profile?['first_name'] ?? '');
    final lastCtrl = TextEditingController(
        text: profile?['last_name'] ?? '');
    final emailCtrl = TextEditingController(
        text: profile?['email'] ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Edit Profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 4),
                const Text(
                    'Username changes will be available in a future update.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 24),
                _SheetField(
                    label: 'FIRST NAME',
                    controller: firstCtrl,
                    hint: 'First name'),
                const SizedBox(height: 14),
                _SheetField(
                    label: 'LAST NAME',
                    controller: lastCtrl,
                    hint: 'Last name'),
                const SizedBox(height: 14),
                _SheetField(
                    label: 'EMAIL ADDRESS',
                    controller: emailCtrl,
                    hint: 'Email address',
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 8),
                const Text(
                    'Email changes require re-verification.',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setSheetState(
                                () => saving = true);
                            try {
                              final userId = Supabase
                                  .instance
                                  .client
                                  .auth
                                  .currentUser
                                  ?.id;
                              if (userId != null) {
                                await Supabase
                                    .instance.client
                                    .from('profiles')
                                    .update({
                                  'first_name': firstCtrl
                                      .text
                                      .trim(),
                                  'last_name': lastCtrl
                                      .text
                                      .trim(),
                                  'email': emailCtrl
                                      .text
                                      .trim(),
                                }).eq('id', userId);
                                ref.invalidate(
                                    profileProvider);
                              }
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                            } catch (_) {
                              setSheetState(
                                  () => saving = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Change Password Sheet ────────────────────────────────
  void _showChangePassword(BuildContext context) {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Change Password',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 24),
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.criticalBorder),
                    ),
                    child: Text(error!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryLight,
                            fontFamily: 'Inter')),
                  ),
                  const SizedBox(height: 16),
                ],
                _SheetField(
                    label: 'NEW PASSWORD',
                    controller: newCtrl,
                    hint: 'Enter new password',
                    obscure: true),
                const SizedBox(height: 14),
                _SheetField(
                    label: 'CONFIRM PASSWORD',
                    controller: confirmCtrl,
                    hint: 'Confirm new password',
                    obscure: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (newCtrl.text.length < 8) {
                              setSheetState(() => error =
                                  'Password must be at least 8 characters.');
                              return;
                            }
                            if (newCtrl.text !=
                                confirmCtrl.text) {
                              setSheetState(() =>
                                  error = 'Passwords do not match.');
                              return;
                            }
                            setSheetState(
                                () => saving = true);
                            try {
                              await Supabase.instance.client
                                  .auth
                                  .updateUser(UserAttributes(
                                      password:
                                          newCtrl.text));
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                            } on AuthException catch (e) {
                              setSheetState(() {
                                error = e.message;
                                saving = false;
                              });
                            } catch (_) {
                              setSheetState(() {
                                error =
                                    'Something went wrong.';
                                saving = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                        : const Text('Update Password',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign Out Confirmation ────────────────────────────────
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter')),
        content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
                fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  // ── Delete Account Confirmation ──────────────────────────
  void _confirmDeleteAccount(BuildContext context) {
    final confirmCtrl = TextEditingController();
    const confirmWord = 'DELETE';
    bool deleting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Account',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontFamily: 'Inter')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will permanently delete your account, all your vehicles, scan history, and bookings. This cannot be undone.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontFamily: 'Inter'),
              ),
              const SizedBox(height: 16),
              Text(
                'Type "$confirmWord" to confirm:',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                autofocus: true,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: confirmWord,
                  hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter'),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
            TextButton(
              onPressed: confirmCtrl.text == confirmWord &&
                      !deleting
                  ? () async {
                      setDialogState(() => deleting = true);
                      try {
                        final userId = Supabase
                            .instance.client.auth.currentUser?.id;
                        if (userId != null) {
                          // Delete profile (cascades to vehicles, scans etc)
                          await Supabase.instance.client
                              .from('profiles')
                              .delete()
                              .eq('id', userId);
                          await AuthService().signOut();
                        }
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (context.mounted) {
                          Navigator.of(context)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen()),
                            (route) => false,
                          );
                        }
                      } catch (_) {
                        setDialogState(
                            () => deleting = false);
                      }
                    }
                  : null,
              child: deleting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2))
                  : Text('Delete Forever',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: confirmCtrl.text == confirmWord
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontFamily: 'Inter')),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SUPPORTING WIDGETS ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRed;
  const _SectionLabel({required this.label, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isRed
                ? AppColors.primary
                : AppColors.textTertiary,
            letterSpacing: 1.5,
            fontFamily: 'Inter'));
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primarySubtle
                  : AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: value
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter')),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor:
                AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle, trailing;
  final bool isDestructive, showChevron;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.isDestructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.primary : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
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
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.criticalBg
                    : AppColors.surfaceDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                          fontFamily: 'Inter')),
                  if (subtitle != null &&
                      subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter')),
            if (showChevron) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboard;
  final bool obscure;

  const _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard = TextInputType.text,
    this.obscure = false,
  });

  @override
  State<_SheetField> createState() => _SheetFieldState();
}

class _SheetFieldState extends State<_SheetField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboard,
          obscureText: _obscure,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textDisabled,
                fontFamily: 'Inter'),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: widget.obscure
                ? GestureDetector(
                    onTap: () =>
                        setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

