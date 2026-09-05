// Mechanic Profile screen (own view) — mechanic views their own profile.
// Lives in profile/screens/ — different from the user-facing mechanic
// profile in mechanics/screens/mechanic_profile_screen.dart.
// Matches design/profile_screens.html Screen 2: back + title + edit-pencil
// header, centered avatar/name/username, then a divided field list.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/auth/models/mechanic_model.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/profile_field_row.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicProfileOwnScreen extends ConsumerStatefulWidget {
  const MechanicProfileOwnScreen({super.key});

  @override
  ConsumerState<MechanicProfileOwnScreen> createState() =>
      _MechanicProfileOwnScreenState();
}

class _MechanicProfileOwnScreenState
    extends ConsumerState<MechanicProfileOwnScreen> {
  bool _isLoading = true;
  UserModel? _user;
  MechanicModel? _mechanic;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _load();
  }

  // One-time fetch, deliberately not the app-wide profile stream — see the
  // same note in user_profile_screen.dart.
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
      if (!mounted) return;
      setState(() {
        _user = userDoc.exists
            ? UserModel.fromFirestore(userDoc)
            : UserModel.fromFirebaseUser(authUser);
        _mechanic = mechanicDoc.exists
            ? MechanicModel.fromFirestore(mechanicDoc)
            : null;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.handle(
          e,
          stackTrace,
          screen: 'MechanicProfileOwnScreen',
          userId: FirebaseAuth.instance.currentUser?.uid,
        ).message;
      });
    }
  }

  void _copyMechanicId() {
    final id = _mechanic?.uid;
    if (id == null) return;
    Clipboard.setData(ClipboardData(text: id));
    AppErrorToast.showMessage(context, 'Mechanic ID copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'My Profile',
              subtitle: 'Manage your account',
              trailingIcon: Icons.edit_outlined,
              onTrailingTap: () => context.go(RouteNames.mechanicProfileEdit),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) return const _ProfileSkeletonView();
                  if (_errorMessage != null) {
                    return _ProfileErrorView(
                      message: _errorMessage!,
                      onRetry: _load,
                    );
                  }

                  final user = _user!;
                  final name = user.fullName.trim().isNotEmpty
                      ? user.fullName
                      : user.username;
                  final expertise = _mechanic?.expertise ?? const <String>[];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        AppAvatar(
                          name: name,
                          imageUrl: user.profilePhoto,
                          size: 84 * 2,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: AppTypography.heading3,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 18),
                        Divider(height: 1, color: AppColors.borderSubtle),
                        ProfileFieldRow(
                          label: 'Full Name',
                          value: user.fullName,
                        ),
                        ProfileFieldRow(
                          label: 'Username',
                          value: '@${user.username}',
                        ),
                        ProfileFieldRow(label: 'Email', value: user.email),
                        ProfileFieldRow(label: 'Phone', value: user.phone),
                        ProfileFieldRow(
                          label: 'Workshop',
                          value: _mechanic?.workshopAddress ?? '',
                        ),
                        ProfileFieldRow(
                          label: 'Experience',
                          value: _mechanic == null
                              ? ''
                              : '${_mechanic!.yearsOfExperience} years',
                        ),
                        ProfileFieldRow(
                          label: 'Expertise',
                          value: expertise.isEmpty
                              ? 'No expertise added yet'
                              : expertise.join(' · '),
                          dimmed: true,
                        ),
                        ProfileFieldRow(
                          label: 'Rating',
                          value: _mechanic == null
                              ? ''
                              : '★ ${_mechanic!.rating.toStringAsFixed(1)} · ${_mechanic!.totalJobs} jobs completed',
                          dimmed: true,
                        ),
                        ProfileFieldRow(
                          label: 'Your Mechanic ID',
                          value: _mechanic?.uid ?? '',
                          onTap: _mechanic == null ? null : _copyMechanicId,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSkeletonView extends StatelessWidget {
  const _ProfileSkeletonView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const AppSkeleton.circle(size: 84),
          const SizedBox(height: 12),
          const AppSkeleton(width: 120, height: 16, radius: AppRadius.xs),
          const SizedBox(height: 8),
          const AppSkeleton(width: 80, height: 11, radius: AppRadius.xs),
          const SizedBox(height: 18),
          Divider(height: 1, color: AppColors.borderSubtle),
          for (int i = 0; i < 7; i++)
            ProfileFieldRowSkeleton(valueWidth: i.isEven ? 160 : 120),
        ],
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Try again',
                style: AppTypography.body.copyWith(color: AppColors.primary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
