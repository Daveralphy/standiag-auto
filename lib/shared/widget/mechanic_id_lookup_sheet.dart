// "Schedule Repair" entry point — a car owner who already has a specific
// mechanic's ID looks them up here, confirms it's the right person, then
// continues into FindMechanicSheet with that mechanic as the request's
// target instead of broadcasting to everyone nearby.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../features/auth/models/mechanic_model.dart';
import '../../features/mechanics/providers/mechanics_provider.dart';
import 'app_avatar.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'find_mechanic_sheet.dart';

class MechanicIdLookupSheet {
  MechanicIdLookupSheet._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MechanicIdLookupSheetContent(
        onContinue: (mechanicId, mechanicName) {
          FindMechanicSheet.show(
            context,
            targetMechanicId: mechanicId,
            targetMechanicName: mechanicName,
          );
        },
      ),
    );
  }
}

class _MechanicIdLookupSheetContent extends ConsumerStatefulWidget {
  final void Function(String mechanicId, String mechanicName) onContinue;
  const _MechanicIdLookupSheetContent({required this.onContinue});

  @override
  ConsumerState<_MechanicIdLookupSheetContent> createState() =>
      _MechanicIdLookupSheetContentState();
}

class _MechanicIdLookupSheetContentState
    extends ConsumerState<_MechanicIdLookupSheetContent> {
  final _idController = TextEditingController();
  bool _isSearching = false;
  bool _searched = false;
  MechanicModel? _found;
  String _foundName = '';

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;
    setState(() {
      _isSearching = true;
      _searched = false;
      _found = null;
    });

    final mechanic = await ref.read(mechanicByIdProvider(id).future);
    if (!mounted) return;

    if (mechanic == null || !mechanic.isVisible) {
      setState(() {
        _isSearching = false;
        _searched = true;
        _found = null;
      });
      return;
    }

    final user = await ref.read(mechanicUserProvider(id).future);
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _searched = true;
      _found = mechanic;
      _foundName = user != null
          ? '${user.firstName} ${user.lastName}'.trim()
          : 'Mechanic';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl5),
            ),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl4,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: Text(
                  'Schedule Repair',
                  style: AppTypography.heading3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl4,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl2,
                  ),
                  children: [
                    const Text(
                      'Enter a mechanic\'s ID to request them directly, '
                      'wherever they are.',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Mechanic ID',
                      controller: _idController,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _search,
                      textInputAction: TextInputAction.search,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Search',
                      isLoading: _isSearching,
                      onTap: _idController.text.trim().isEmpty ? null : _search,
                    ),
                    const SizedBox(height: 20),
                    if (_searched && _found == null)
                      const Text(
                        'No mechanic found with that ID.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (_found != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            AppAvatar(name: _foundName, size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _foundName,
                                    style: AppTypography.heading4,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.primary,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _found!.rating.toStringAsFixed(1),
                                        style: AppTypography.caption,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_found!.totalJobs} jobs',
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'Continue',
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onContinue(_found!.uid, _foundName);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
