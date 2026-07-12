// Delete Account screen — confirmation modal over dimmed settings background.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Future<void> _deleteUserSubcollection(
      String collection, String field, String uid) async {
    final firestore = FirebaseFirestore.instance;
    final docs = await firestore
        .collection(collection)
        .where(field, isEqualTo: uid)
        .get();
    for (final doc in docs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = user.uid;
      await _deleteUserSubcollection('vehicles', 'ownerId', uid);
      await _deleteUserSubcollection('scans', 'ownerId', uid);
      await _deleteUserSubcollection('credits_history', 'userId', uid);
      await FirebaseFirestore.instance.collection('mechanics').doc(uid).delete();
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user.delete();
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      context.go(RouteNames.onboarding);
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(error, stackTrace).message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(currentUserTypeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                      AppSpacing.pageHorizontal,
                      0,
                    ),
                    child: Text(
                      AppStrings.settingsTitle,
                      style: AppTypography.heading3,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  ...[
                    AppStrings.settingsNotifications,
                    AppStrings.settingsLanguage,
                    AppStrings.settingsAppearance,
                    AppStrings.settingsPrivacy,
                    AppStrings.settingsChangePassword,
                  ].map(
                    (setting) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal,
                        14,
                        AppSpacing.pageHorizontal,
                        0,
                      ),
                      child: Text(
                        setting,
                        style: AppTypography.body,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(color: const Color(0xB8000000)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl2),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl2,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.modal),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.settingsFor(type));
                        }
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0x0FFFFFFF),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    AppStrings.deleteAccountTitle,
                    style: AppTypography.heading3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.deleteAccountMessage,
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(
                      child: AppButton(
                        label: AppStrings.deleteAccountCancel,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteNames.settingsFor(type));
                          }
                        },
                        variant: AppButtonVariant.ghost,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: AppStrings.deleteAccountConfirm,
                        onTap: _deleteAccount,
                        variant: AppButtonVariant.danger,
                        isLoading: _isLoading,
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
