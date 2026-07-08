// Mechanic Profile Edit screen — mechanic edits their profile details.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicProfileEditScreen extends StatefulWidget {
  const MechanicProfileEditScreen({super.key});

  @override
  State<MechanicProfileEditScreen> createState() =>
      _MechanicProfileEditScreenState();
}

class _MechanicProfileEditScreenState
    extends State<MechanicProfileEditScreen> {
  final _firstNameController = TextEditingController(text: 'Kwame');
  final _lastNameController = TextEditingController(text: 'Asante');
  final _workshopController =
      TextEditingController(text: '14 Park Avenue, Lekki');
  final _experienceController = TextEditingController(text: '8');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _workshopController.dispose();
    _experienceController.dispose();
    super.dispose();
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
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Edit Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(label: AppStrings.fieldFirstName,
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.fieldLastName,
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.fieldWorkshop,
                        controller: _workshopController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.fieldExperience,
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: AppStrings.profileSave,
                      onTap: () {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) return;
                        setState(() => _isLoading = true);
                        FirebaseFirestore.instance.collection('users').doc(userId).update({
                          'firstName': _firstNameController.text.trim(),
                          'lastName': _lastNameController.text.trim(),
                          'address': _workshopController.text.trim(),
                        }).then((_) {
                          if (!context.mounted) return;
                          setState(() => _isLoading = false);
                          context.go(RouteNames.mechanicProfileView);
                        }).catchError((error, stackTrace) {
                          if (!context.mounted) return;
                          setState(() => _isLoading = false);
                          AppErrorToast.showMessage(
                            context,
                            ErrorHandler.handle(error, stackTrace).message,
                          );
                        });
                      },
                      isLoading: _isLoading,
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