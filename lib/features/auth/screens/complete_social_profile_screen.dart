// Complete Social Profile screen — reached right after a *new* Google or
// Apple sign-in. That account exists in Firebase Auth but has no StanDiag
// profile yet (no users/{uid} doc), since the social flow skips the
// multi-step email signup wizard that normally collects account type and
// a username. Asks for exactly those two things, then creates the same
// Firestore documents AuthController.signUp() would have.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../auth/models/mechanic_model.dart';
import '../models/user_model.dart';

class CompleteSocialProfileScreen extends ConsumerStatefulWidget {
  const CompleteSocialProfileScreen({super.key});

  @override
  ConsumerState<CompleteSocialProfileScreen> createState() =>
      _CompleteSocialProfileScreenState();
}

class _CompleteSocialProfileScreenState
    extends ConsumerState<CompleteSocialProfileScreen> {
  UserType _selected = UserType.carOwner;
  final _usernameController = TextEditingController();
  bool _isSaving = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.contains('@')) {
      _usernameController.text = email.split('@').first;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _usernameError = 'Choose a username to continue.');
      return;
    }

    setState(() {
      _isSaving = true;
      _usernameError = null;
    });
    try {
      final firestore = FirebaseFirestore.instance;
      final usernameRef = firestore.collection('usernames').doc(username);
      final usernameDoc = await usernameRef.get();
      if (usernameDoc.exists && usernameDoc.data()?['uid'] != user.uid) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _usernameError = 'That username is already taken.';
        });
        return;
      }

      final base = UserModel.fromFirebaseUser(user);
      final profile = UserModel(
        uid: base.uid,
        type: _selected,
        firstName: base.firstName,
        lastName: base.lastName,
        username: username,
        email: base.email,
        phone: base.phone,
        address: base.address,
        profilePhoto: base.profilePhoto,
        credits: 0,
        createdAt: DateTime.now(),
        isFirstTime: true,
      );
      await firestore.collection('users').doc(user.uid).set(profile.toFirestore());
      await usernameRef.set({'uid': user.uid, 'email': profile.email});

      if (_selected == UserType.mechanic) {
        await firestore.collection('mechanics').doc(user.uid).set(
              MechanicModel(
                uid: user.uid,
                workshopAddress: '',
                expertise: const [],
                yearsOfExperience: 0,
                rating: 0,
                totalJobs: 0,
                credits: 0,
                isVisible: true,
              ).toFirestore(),
            );
      }

      if (!mounted) return;
      context.go(RouteNames.homeFor(_selected));
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(error, stackTrace,
                screen: 'CompleteSocialProfileScreen')
            .message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.xl2,
            AppSpacing.pageHorizontal,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('One last step', style: AppTypography.heading2),
              const SizedBox(height: 6),
              Text(
                'Tell us a bit more so we can set up your StanDiag account.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 24),
              Text('I am a...', style: AppTypography.heading4),
              const SizedBox(height: 10),
              _TypeOption(
                title: 'Car Owner',
                subtitle: 'I need a mechanic',
                selected: _selected == UserType.carOwner,
                onTap: () => setState(() => _selected = UserType.carOwner),
              ),
              const SizedBox(height: 10),
              _TypeOption(
                title: 'Mechanic',
                subtitle: 'I fix cars',
                selected: _selected == UserType.mechanic,
                onTap: () => setState(() => _selected = UserType.mechanic),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Username',
                hint: 'Choose a username',
                controller: _usernameController,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_usernameError != null) {
                    setState(() => _usernameError = null);
                  }
                },
              ),
              if (_usernameError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _usernameError!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              AppButton(
                label: 'Continue',
                isLoading: _isSaving,
                onTap: _isSaving ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySubtle : AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
