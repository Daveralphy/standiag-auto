// User Profile Edit screen — car owner edits their profile details.
// Mirrors MechanicProfileEditScreen's pattern (tappable avatar with camera
// overlay + "Change Photo", editable fields, Save Changes) but with the
// CarOwner-relevant fields only: no workshop/experience/expertise/rating.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserProfileEditScreen extends ConsumerStatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  ConsumerState<UserProfileEditScreen> createState() =>
      _UserProfileEditScreenState();
}

class _UserProfileEditScreenState
    extends ConsumerState<UserProfileEditScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You need to be signed in to view this.';
        });
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();
      final user = doc.exists
          ? UserModel.fromFirestore(doc)
          : UserModel.fromFirebaseUser(authUser);
      if (!mounted) return;
      setState(() {
        _nameController.text = user.fullName;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _profilePhotoUrl = user.profilePhoto;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.handle(e, stackTrace,
                screen: 'UserProfileEditScreen',
                userId: FirebaseAuth.instance.currentUser?.uid)
            .message;
      });
    }
  }

  Future<void> _changePhoto() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePhoto': url});
      if (!mounted) return;
      setState(() {
        _profilePhotoUrl = url;
        _isUploadingPhoto = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(e, stackTrace, screen: 'UserProfileEditScreen')
            .message,
      );
    }
  }

  Future<void> _save() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    setState(() => _isSaving = true);
    try {
      final nameParts = _nameController.text.trim().split(' ');
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'firstName': nameParts.first,
        'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });
      if (!mounted) return;
      setState(() => _isSaving = false);
      context.go(RouteNames.userProfile);
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(error, stackTrace,
                screen: 'UserProfileEditScreen')
            .message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.go(RouteNames.userProfile),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(AppStrings.profileTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                GestureDetector(
                  onTap: () => context.go(RouteNames.userProfile),
                  child: Text('Cancel',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      )),
                ),
              ]),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2))
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: AppColors.textMuted, size: 32),
                                const SizedBox(height: 12),
                                Text(_errorMessage!,
                                    style: AppTypography.bodyLarge,
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _load,
                                  child: Text('Try again',
                                      style: AppTypography.body.copyWith(
                                          color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _isUploadingPhoto ? null : _changePhoto,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AppAvatar(
                                      name: _nameController.text,
                                      imageUrl: _profilePhotoUrl,
                                      size: 84,
                                    ),
                                    if (_isUploadingPhoto)
                                      Container(
                                        width: 84, height: 84,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0x99000000),
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 84, height: 84,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0x73000000),
                                        ),
                                        child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.white, size: 20),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Change Photo',
                                  style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  )),
                              const SizedBox(height: 22),
                              AppTextField(label: AppStrings.fieldFullName,
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: AppStrings.fieldUsername,
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: AppStrings.fieldEmail,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: AppStrings.fieldPhone,
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: AppStrings.fieldAddress,
                                  controller: _addressController,
                                  textInputAction: TextInputAction.done),
                              const SizedBox(height: 24),
                              AppButton(
                                label: 'Save Changes',
                                onTap: _isSaving ? null : _save,
                                isLoading: _isSaving,
                              ),
                              const SizedBox(height: 24),
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
