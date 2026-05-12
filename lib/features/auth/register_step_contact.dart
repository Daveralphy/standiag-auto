import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/register_state.dart';
import '../../core/widgets/app_toast.dart';

class RegisterStepContact extends StatefulWidget {
  final RegisterState state;
  final void Function(RegisterState) onNext;
  final VoidCallback onBack;

  const RegisterStepContact({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterStepContact> createState() => _RegisterStepContactState();
}

class _RegisterStepContactState extends State<RegisterStepContact> {
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _zipCtrl      = TextEditingController();
  final _countryCtrl  = TextEditingController();
  final String _countryCode = '+234';
  final String _countryFlag = '\u{1F1F3}\u{1F1EC}';
  bool _locLoading    = false;

  bool get _isMechanic => widget.state.accountType == 'mechanic';

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text   = widget.state.phone;
    _countryCtrl.text = 'Nigeria';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _useLocation() async {
    setState(() => _locLoading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        AppToast.error(context,
            'Location permission denied. Please enable it in settings.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      // Pre-fill with coordinates â€” user can edit
      _addressCtrl.text =
      _addressCtrl.text = pos.latitude.toStringAsFixed(4) + ', ' + pos.longitude.toStringAsFixed(4);
      AppToast.success(context, 'Location captured. Please complete the address.');
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, 'Could not get location. Please enter manually.');
    } finally {
      if (mounted) setState(() => _locLoading = false);
    }
  }

  void _next() {
    if (_phoneCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter your phone number.');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter your email address.');
      return;
    }
    if (_isMechanic && _addressCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter your workshop address.');
      return;
    }
    final address = [
      _addressCtrl.text.trim(),
      _cityCtrl.text.trim(),
      _zipCtrl.text.trim(),
      _countryCtrl.text.trim(),
    ].where((s) => s.isNotEmpty).join(', ');
    widget.onNext(widget.state.copyWith(
      phone: _phoneCtrl.text.trim(),
      countryCode: _countryCode,
      address: address,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€ Back â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onBack,
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textTertiary, size: 22),
              ),
              const SizedBox(height: 20),
              // â”€â”€ Step tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _StepTabs(currentStep: 2),
              const SizedBox(height: 40),
              // â”€â”€ Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text('How do we\nreach you?',
                  style: AppTypography.h1.copyWith(
                      fontSize: 28, letterSpacing: -0.6,
                      height: 1.15)),
              const SizedBox(height: 8),
              Text('We\u2019ll never share your contact details.',
                  style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              // â”€â”€ Phone number â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _PhoneField(
                controller: _phoneCtrl,
                flag: _countryFlag,
                code: _countryCode,
              ),
              const SizedBox(height: 22),
              // â”€â”€ Email â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _FloatingField(
                label: 'Email Address',
                hint: 'Enter email address',
                controller: _emailCtrl,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              // â”€â”€ Address â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _AddressField(
                label: _isMechanic ? 'Workshop Address' : 'Address (Optional)',
                controller: _addressCtrl,
                locLoading: _locLoading,
                onUseLocation: _useLocation,
              ),

              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _FloatingField(
                      label: _isMechanic ? 'City' : 'City (Optional)',
                      hint: 'Enter city',
                      controller: _cityCtrl,
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FloatingField(
                      label: _isMechanic ? 'ZIP' : 'ZIP (Optional)',
                      hint: 'ZIP code',
                      controller: _zipCtrl,
                      icon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              _FloatingField(
                label: 'Country',
                hint: 'Enter country',
                controller: _countryCtrl,
                icon: Icons.public_outlined,
              ),

              const SizedBox(height: 40),
              // â”€â”€ Next button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _next,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.lgAll,
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  child: Center(
                    child: Text('NEXT',
                        style: AppTypography.button.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Step tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StepTabs extends StatelessWidget {
  final int currentStep;
  const _StepTabs({required this.currentStep});
  static const _labels = [
    'Getting\nStarted', 'Your\nDetails', 'Contact\nInfo',
    'Vehicle /\nExpertise', 'Your\nIdentity',
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentStep;
        final isDone   = i < currentStep;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 24 : 8, height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary
                            : isDone ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border,
                        borderRadius: isActive ? AppRadius.smAll : AppRadius.fullAll,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_labels[i],
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 10, height: 1.3)),
                  ],
                ),
              ),
              if (i < _labels.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    width: 8, height: 2,
                    color: isDone
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// â”€â”€ Floating label text field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;


  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,

  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textTertiary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textInputAction: TextInputAction.next,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textDisabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ]),
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Phone field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String flag;
  final String code;

  const _PhoneField({
    required this.controller,
    required this.flag,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            // Country code selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(code,
                      style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary, size: 18),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textDisabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ]),
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('Phone Number',
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Address field with location button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AddressField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool locLoading;
  final VoidCallback onUseLocation;

  const _AddressField({
    required this.label,
    required this.controller,
    required this.locLoading,
    required this.onUseLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Text input row
              SizedBox(
                height: 56,
                child: Row(children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.textTertiary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.next,
                      style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter street address',
                        hintStyle: AppTypography.body.copyWith(
                            color: AppColors.textDisabled),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ]),
              ),
              // Use location button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: locLoading ? null : onUseLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    border: Border(top: BorderSide(
                        color: AppColors.primaryBorder)),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      locLoading
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.my_location_rounded,
                              color: AppColors.primary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        locLoading ? 'Getting location...' : 'Use my current location',
                        style: AppTypography.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

