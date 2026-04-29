import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_field.dart';
import '../../core/providers/auth_provider.dart';
import 'register_screen.dart';
import 'register_screen_step3.dart';
import 'register_helpers.dart';

class _Country {
  final String name;
  final String dialCode;
  final String flag;
  const _Country({required this.name, required this.dialCode, required this.flag});
}

class RegisterScreenStep2 extends ConsumerStatefulWidget {
  const RegisterScreenStep2({super.key});

  @override
  ConsumerState<RegisterScreenStep2> createState() => _RegisterScreenStep2State();
}

class _RegisterScreenStep2State extends ConsumerState<RegisterScreenStep2> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _errorMessage;

  List<_Country> _countries = [];
  bool _loadingCountries = true;
  _Country? _selected;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    try {
      final client = HttpClient();
      final req = await client.getUrl(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,idd,flag'),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      final List<dynamic> raw = jsonDecode(body);
      final parsed = <_Country>[];

      for (final item in raw) {
        final name = item['name']?['common'] as String? ?? '';
        final flag = item['flag'] as String? ?? '';
        final root = item['idd']?['root'] as String? ?? '';
        final suffixes = item['idd']?['suffixes'] as List<dynamic>?;

        if (name.isEmpty || root.isEmpty) continue;

        // Only include countries with a single suffix to avoid ambiguity
        if (suffixes != null && suffixes.length == 1) {
          final dialCode = '$root${suffixes[0]}';
          parsed.add(_Country(name: name, dialCode: dialCode, flag: flag));
        } else if (suffixes == null || suffixes.isEmpty) {
          // Country uses root alone (e.g. +1 for some territories)
          parsed.add(_Country(name: name, dialCode: root, flag: flag));
        }
      }

      parsed.sort((a, b) => a.name.compareTo(b.name));

      // Default to Nigeria
      final nigeria = parsed.firstWhere(
        (c) => c.dialCode == '+234',
        orElse: () => parsed.first,
      );

      if (mounted) {
        setState(() {
          _countries = parsed;
          _selected = nigeria;
          _loadingCountries = false;
        });
      }
    } catch (_) {
      // Fallback to common codes on error
      if (mounted) {
        final fallback = [
          const _Country(name: 'Nigeria', dialCode: '+234', flag: '🇳🇬'),
          const _Country(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
          const _Country(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
          const _Country(name: 'Ghana', dialCode: '+233', flag: '🇬🇭'),
          const _Country(name: 'Kenya', dialCode: '+254', flag: '🇰🇪'),
          const _Country(name: 'South Africa', dialCode: '+27', flag: '🇿🇦'),
          const _Country(name: "Côte d'Ivoire", dialCode: '+225', flag: '🇨🇮'),
          const _Country(name: 'India', dialCode: '+91', flag: '🇮🇳'),
          const _Country(name: 'France', dialCode: '+33', flag: '🇫🇷'),
          const _Country(name: 'Germany', dialCode: '+49', flag: '🇩🇪'),
        ];
        setState(() {
          _countries = fallback;
          _selected = fallback.first;
          _loadingCountries = false;
        });
      }
    }
  }

  void _next() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    ref.read(registrationProvider.notifier).setStep2(
      email,
      _phoneController.text.trim(),
      _selected?.dialCode ?? '+234',
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreenStep3()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.50),
              const SizedBox(height: 24),
              buildHeading('How do we', 'reach you?'),
              const SizedBox(height: 6),
              const Text("We'll never share your contact details.",
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                errorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              AppField(
                label: 'Email Address',
                hint: 'Enter your email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Phone with country code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PHONE NUMBER', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _loadingCountries
                            ? const SizedBox(
                                width: 80, height: 48,
                                child: Center(
                                  child: SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary, strokeWidth: 2),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<_Country>(
                                  value: _selected,
                                  dropdownColor: AppColors.surfaceCard,
                                  style: AppTextStyles.inputText,
                                  onChanged: (v) {
                                    if (v != null) setState(() => _selected = v);
                                  },
                                  items: _countries
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text('${c.flag} ${c.dialCode}'),
                                          ))
                                      .toList(),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: AppTextStyles.inputText,
                          decoration: InputDecoration(
                            hintText: 'Phone number',
                            hintStyle: AppTextStyles.hintText,
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your phone number is used for account recovery.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              primaryButton('CONTINUE', _next),
            ],
          ),
        ),
      ),
    );
  }
}
