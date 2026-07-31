// Send Quote screen — a mechanic reviews a car owner's open request (issue,
// distance) and responds with a price and an optional short note. Reachable
// from a nearby-request tile or map pin; resubmitting just overwrites this
// mechanic's existing quote on the request (see ServiceRequestNotifier.
// submitQuote), so this screen also works as "edit my quote".

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/service_request_model.dart';
import '../../jobs/providers/service_request_provider.dart';
import '../providers/mechanics_provider.dart';

class SendQuoteScreen extends ConsumerStatefulWidget {
  final String requestId;
  const SendQuoteScreen({super.key, required this.requestId});

  @override
  ConsumerState<SendQuoteScreen> createState() => _SendQuoteScreenState();
}

class _SendQuoteScreenState extends ConsumerState<SendQuoteScreen> {
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _loadedExistingQuote = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _loadExistingQuote();
  }

  Future<void> _loadExistingQuote() async {
    final mechanicId = ref.read(currentUserIdProvider);
    if (mechanicId == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(widget.requestId)
        .collection('quotes')
        .doc(mechanicId)
        .get();
    if (!mounted || !doc.exists) return;
    final data = doc.data()!;
    setState(() {
      _priceController.text = ((data['price'] as num?) ?? 0).toStringAsFixed(0);
      _noteController.text = data['note'] as String? ?? '';
      _loadedExistingQuote = true;
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return;
    final mechanicId = ref.read(currentUserIdProvider);
    if (mechanicId == null) return;

    setState(() => _isSubmitting = true);
    await ref.read(serviceRequestProvider.notifier).submitQuote(
          requestId: widget.requestId,
          mechanicId: mechanicId,
          price: price,
          note: _noteController.text.trim(),
        );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(serviceRequestByIdProvider(widget.requestId));
    final mechanicId = ref.watch(currentUserIdProvider);
    final mechanicLocation = mechanicId == null
        ? null
        : ref.watch(mechanicByIdProvider(mechanicId)).valueOrNull?.location;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: requestAsync.when(
          data: (request) {
            if (request == null ||
                request.status != ServiceRequestStatus.open) {
              return _buildUnavailable(context);
            }
            return _buildForm(context, request, mechanicLocation);
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, __) => _buildUnavailable(context),
        ),
      ),
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, 'Request Unavailable'),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: Text(
                'This request has already been matched with another mechanic or was cancelled.',
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
          AppSpacing.md, AppSpacing.pageHorizontal, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0x12FFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: AppTypography.heading3,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
      BuildContext context, ServiceRequestModel request, GeoPoint? mechanicLocation) {
    final ownerAsync = ref.watch(mechanicUserProvider(request.carOwnerId));
    final owner = ownerAsync.valueOrNull;
    final ownerName =
        owner != null ? '${owner.firstName} ${owner.lastName}'.trim() : 'Car Owner';

    double? distanceKm;
    if (mechanicLocation != null && request.carOwnerLocation != null) {
      distanceKm = Geolocator.distanceBetween(
            mechanicLocation.latitude,
            mechanicLocation.longitude,
            request.carOwnerLocation!.latitude,
            request.carOwnerLocation!.longitude,
          ) /
          1000;
    }

    return Column(
      children: [
        _buildHeader(context, 'Send a Quote'),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                          name: ownerName, imageUrl: owner?.profilePhoto, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ownerName,
                                style: AppTypography.heading4,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            const SizedBox(height: 3),
                            Text(request.issue,
                                style: AppTypography.bodySmall,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                            if (distanceKm != null) ...[
                              const SizedBox(height: 3),
                              Text('${distanceKm.toStringAsFixed(1)} km away',
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.primary),
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Your Quote',
                    style: AppTypography.heading4,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  style: AppTypography.input,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    prefixText: '₦ ',
                    prefixStyle: AppTypography.input,
                    hintText: 'Price',
                    hintStyle: AppTypography.inputLabel,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: AppTypography.input,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Add a short note (optional) — e.g. "Can be there in 15 min"',
                    hintStyle: AppTypography.inputLabel,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _loadedExistingQuote ? 'Update Quote' : 'Send Quote',
                  isLoading: _isSubmitting,
                  onTap: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
