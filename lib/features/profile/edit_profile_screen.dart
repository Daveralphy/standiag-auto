import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  final _imagePicker = ImagePicker();

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

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (image != null && mounted) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to pick image. Please try again.');
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return null;

      final fileName = 'avatar_$userId.jpg';
      final storagePath = 'avatars/$userId/$fileName';

      final file = _selectedImage!;
      final bytes = await file.readAsBytes();

      await Supabase.instance.client.storage
          .from('user_files')
          .uploadBinary(storagePath, bytes, fileOptions: const FileOptions(upsert: true));

      final publicUrl = Supabase.instance.client.storage
          .from('user_files')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to upload image. Please try again.');
      }
      return null;
    }
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

      // Upload image if selected
      String? avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await _uploadImage();
      }

      // Update profile
      final updateData = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      };

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await Supabase.instance.client.from('profiles').update(updateData).eq('id', userId);
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
                    // Photo Upload Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
