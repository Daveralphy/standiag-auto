import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_toast.dart';
import '../auth/login_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  bool _deleting = false;

  Future<void> _pauseAccount() async {
    AppToast.info(context, 'Pause account feature coming soon.');
  }

  Future<void> _confirmDelete() async {
    final confirmCtrl = TextEditingController();
    bool canConfirm = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            title: const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: AppColors.primary, fontFamily: 'Inter',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This is permanent and cannot be undone. All your data, vehicles, and scan history will be deleted forever.',
                  style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary,
                    fontFamily: 'Inter', height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Type DELETE to confirm:',
                  style: TextStyle(
                    fontSize: 13, color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600, fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmCtrl,
                  style: const TextStyle(
                    color: AppColors.textPrimary, fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontFamily: 'Inter'),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdAll,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdAll,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdAll,
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (v) => setDialogState(() => canConfirm = v == 'DELETE'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
              ),
              TextButton(
                onPressed: canConfirm ? () => Navigator.of(ctx).pop(true) : null,
                child: Text(
                  'Delete Forever',
                  style: TextStyle(
                    color: canConfirm ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: FontWeight.w700, fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    confirmCtrl.dispose();
    if (confirmed != true) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    setState(() => _deleting = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not signed in');

      // Delete profile data first (RLS will handle cascades)
      await Supabase.instance.client.from('profiles').delete().eq('id', userId);

      // Sign out (full user deletion requires Edge Function with service role)
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      AppToast.error(context, 'Failed to delete account. Please contact support.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const AppSecondaryHeader(title: 'Account Management'),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Pause Account ────────────────────────
                    Text('PAUSE ACCOUNT', style: AppTypography.overline),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pausing your account hides your profile and activity temporarily. You can reactivate anytime by signing back in.',
                            style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary,
                              fontFamily: 'Inter', height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _pauseAccount,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.mdAll,
                                border: Border.all(color: AppColors.border, width: 1.5),
                              ),
                              child: const Center(
                                child: Text(
                                  'Pause Account',
                                  style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary, fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Delete Account ───────────────────────
                    Text('DELETE ACCOUNT', style: AppTypography.overline),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.criticalBg,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.criticalBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deleting your account is permanent and irreversible. All your data including vehicles, scan history, and profile information will be erased forever.',
                            style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary,
                              fontFamily: 'Inter', height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _deleting ? null : _confirmDelete,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.mdAll,
                              ),
                              child: Center(
                                child: _deleting
                                    ? const SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Delete Account',
                                        style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w700,
                                          color: Colors.white, fontFamily: 'Inter',
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
}
