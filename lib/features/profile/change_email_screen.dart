import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_toast.dart';

class ChangeEmailScreen extends StatefulWidget {
  final String currentEmail;
  const ChangeEmailScreen({super.key, required this.currentEmail});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  late final TextEditingController _newEmailCtrl;
  final _passwordCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _newEmailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newEmail = _newEmailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (newEmail.isEmpty || !newEmail.contains('@')) {
      AppToast.error(context, 'Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      AppToast.error(context, 'Please enter your current password to confirm.');
      return;
    }

    setState(() => _saving = true);
    try {
      // Re-authenticate first
      await Supabase.instance.client.auth.signInWithPassword(
        email: widget.currentEmail,
        password: password,
      );
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      if (!mounted) return;
      AppToast.success(context, 'Email update initiated. Check your new inbox to confirm.');
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to update email. Please try again.');
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
            const AppSecondaryHeader(title: 'Change Email'),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Current email — disabled
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Text('Current email',
                              style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter',
                              )),
                          const Spacer(),
                          Text(widget.currentEmail,
                              style: const TextStyle(
                                fontSize: 13, color: AppColors.textTertiary, fontFamily: 'Inter',
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'New Email',
                      hint: 'Enter your new email address',
                      controller: _newEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'Current Password',
                      hint: 'Enter your password to confirm',
                      controller: _passwordCtrl,
                      obscure: true,
                    ),
                    const SizedBox(height: 32),
                    _SaveButton(saving: _saving, onTap: _save, label: 'Update Email'),
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
  final String label;
  const _SaveButton({required this.saving, required this.onTap, required this.label});

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
              : Text(label, style: AppTypography.button),
        ),
      ),
    );
  }
}
