import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _prefill(Map<String, dynamic>? profile) {
    if (_loaded || profile == null) return;
    _firstNameCtrl.text = profile['first_name'] as String? ?? '';
    _lastNameCtrl.text = profile['last_name'] as String? ?? '';
    _phoneCtrl.text = profile['phone'] as String? ?? '';
    _loaded = true;
  }

  Future<void> _save() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      AppToast.error(context, 'First and last name are required.');
      return;
    }

    setState(() => _saving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not signed in');
      await Supabase.instance.client.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      }).eq('id', userId);
      ref.invalidate(profileProvider);
      if (!mounted) return;
      AppToast.success(context, 'Profile updated successfully.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to update profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    profileAsync.whenData(_prefill);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const AppSecondaryHeader(title: 'Edit Profile'),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    AppField(
                      label: 'First Name',
                      hint: 'Enter your first name',
                      controller: _firstNameCtrl,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      controller: _lastNameCtrl,
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
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
              : const Text('Save Changes', style: AppTypography.button),
        ),
      ),
    );
  }
}
