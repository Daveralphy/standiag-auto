// Mechanic Profile Edit screen — mechanic edits their profile details.
// Matches design/profile_screens.html Screen 3: back + title + "Cancel"
// header, tappable avatar with camera overlay + "Change Photo", editable
// fields, then locked Expertise/Rating display fields, Save Changes button.

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
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../features/auth/models/mechanic_model.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicProfileEditScreen extends ConsumerStatefulWidget {
  const MechanicProfileEditScreen({super.key});

  @override
  ConsumerState<MechanicProfileEditScreen> createState() =>
      _MechanicProfileEditScreenState();
}

class _MechanicProfileEditScreenState
    extends ConsumerState<MechanicProfileEditScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workshopController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;
  String? _profilePhotoUrl;
  List<String> _expertise = const [];
  double _rating = 0;
  int _totalJobs = 0;

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
    _workshopController.dispose();
    _experienceController.dispose();
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
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();
      final mechanicDoc = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(authUser.uid)
          .get();
      final user = userDoc.exists
          ? UserModel.fromFirestore(userDoc)
          : UserModel.fromFirebaseUser(authUser);
      final mechanic =
          mechanicDoc.exists ? MechanicModel.fromFirestore(mechanicDoc) : null;
      if (!mounted) return;
      setState(() {
        _nameController.text = user.fullName;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _workshopController.text = mechanic?.workshopAddress ?? '';
        _experienceController.text =
            (mechanic?.yearsOfExperience ?? 0).toString();
        _profilePhotoUrl = user.profilePhoto;
        _expertise = mechanic?.expertise ?? const [];
        _rating = mechanic?.rating ?? 0;
        _totalJobs = mechanic?.totalJobs ?? 0;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.handle(e, stackTrace,
                screen: 'MechanicProfileEditScreen',
                userId: FirebaseAuth.instance.currentUser?.uid)
            .message;
      });
    }
  }

  Future<void> _changePhoto() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
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
        ErrorHandler.handle(e, stackTrace, screen: 'MechanicProfileEditScreen')
            .message,
      );
    }
  }

  Future<void> _save() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    setState(() => _isSaving = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final nameParts = _nameController.text.trim().split(' ');
      await firestore.collection('users').doc(userId).update({
        'firstName': nameParts.first,
        'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      await firestore.collection('mechanics').doc(userId).update({
        'workshopAddress': _workshopController.text.trim(),
        'yearsOfExperience':
            int.tryParse(_experienceController.text.trim()) ?? 0,
      });
      if (!mounted) return;
      setState(() => _isSaving = false);
      context.go(RouteNames.mechanicProfileView);
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(error, stackTrace,
                screen: 'MechanicProfileEditScreen')
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
                  onTap: () => context.go(RouteNames.mechanicProfileView),
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
                Expanded(child: Text('My Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                GestureDetector(
                  onTap: () => context.go(RouteNames.mechanicProfileView),
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
                              AppTextField(label: 'Full Name',
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: 'Username',
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: 'Email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: 'Phone',
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: 'Workshop Address',
                                  controller: _workshopController,
                                  textInputAction: TextInputAction.next),
                              const SizedBox(height: 16),
                              AppTextField(label: 'Years of Experience',
                                  controller: _experienceController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done),
                              const SizedBox(height: 20),
                              _LockedField(
                                label: 'Expertise',
                                value: _expertise.isEmpty
                                    ? 'No expertise added yet'
                                    : _expertise.join(' · '),
                              ),
                              const SizedBox(height: 10),
                              _LockedField(
                                label: 'Rating',
                                value: '★ ${_rating.toStringAsFixed(1)} · $_totalJobs jobs',
                              ),
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

/// A readonly display field matching design's dimmed "Expertise"/"Rating"
/// boxes in the edit screen — these aren't user-editable here.
class _LockedField extends StatelessWidget {
  final String label;
  final String value;
  const _LockedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600,
              color: AppColors.textDisabled,
            )),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          height: 44,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.borderSubtle,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(value,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                color: AppColors.textDisabled,
              ),
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }
}
