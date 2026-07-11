// Mechanic Profile Edit screen — mechanic edits their profile details.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/user_provider.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _workshopController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isLoading = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  void _prefillOnce(String firstName, String lastName, String workshop, int years) {
    if (_prefilled) return;
    _prefilled = true;
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    _workshopController.text = workshop;
    _experienceController.text = years.toString();
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
    final uid = ref.watch(currentUserIdProvider);
    final userAsync = ref.watch(userProfileProvider);
    final mechanicAsync =
        uid == null ? null : ref.watch(mechanicByIdProvider(uid));
    final user = userAsync.valueOrNull;
    final mechanic = mechanicAsync?.valueOrNull;
    if (user != null && mechanic != null) {
      _prefillOnce(user.firstName, user.lastName, mechanic.workshopAddress,
          mechanic.yearsOfExperience);
    }
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
                      onTap: () async {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) return;
                        setState(() => _isLoading = true);
                        try {
                          final firestore = FirebaseFirestore.instance;
                          await firestore.collection('users').doc(userId).update({
                            'firstName': _firstNameController.text.trim(),
                            'lastName': _lastNameController.text.trim(),
                          });
                          await firestore.collection('mechanics').doc(userId).update({
                            'workshopAddress': _workshopController.text.trim(),
                            'yearsOfExperience':
                                int.tryParse(_experienceController.text.trim()) ?? 0,
                          });
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                          context.go(RouteNames.mechanicProfileView);
                        } catch (error, stackTrace) {
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                          AppErrorToast.showMessage(
                            context,
                            ErrorHandler.handle(error, stackTrace).message,
                          );
                        }
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