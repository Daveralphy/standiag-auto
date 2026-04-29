import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentCtrl.text;
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      AppToast.error(context, 'Please fill in all fields.');
      return;
    }
    if (newPass.length < 8) {
      AppToast.error(context, 'New password must be at least 8 characters.');
      return;
    }
    if (newPass != confirm) {
      AppToast.error(context, 'New passwords do not match.');
      return;
    }

    setState(() => _saving = true);
    try {
      // Re-authenticate to validate current password
      final email = Supabase.instance.client.auth.currentUser?.email ?? '';
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: current,
      );
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );
      if (!mounted) return;
      AppToast.success(context, 'Password changed successfully.');
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to change password. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
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
            const AppSecondaryHeader(title: 'Change Password'),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    AppField(
                      label: 'Current Password',
                      hint: 'Enter your current password',
                      controller: _currentCtrl,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'New Password',
                      hint: 'At least 8 characters',
                      controller: _newCtrl,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'Confirm New Password',
                      hint: 'Repeat your new password',
                      controller: _confirmCtrl,
                      obscure: true,
                    ),
                    const SizedBox(height: 32),
                    _SaveButton(saving: _saving, onTap: _save),
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

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onTap;
  const _SaveButton({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: saving ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: saving ? null : AppColors.primaryGradient,
          color: saving ? AppColors.primary.withValues(alpha: 0.5) : null,
          borderRadius: AppRadius.lgAll,
          boxShadow: saving ? null : AppShadows.primaryGlow,
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Change Password', style: AppTypography.button),
        ),
      ),
    );
  }
}
