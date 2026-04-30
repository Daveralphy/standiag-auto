import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_field.dart';
import '../../core/services/auth_service.dart';
import 'register_helpers.dart';
import '../mechanic/mechanic_navigation.dart';

// ── MECHANIC REGISTRATION DATA ────────────────────────────────
class MechanicRegData {
  final String firstName, lastName, email, phone;
  final String location, bio;
  final List<String> specialisations;
  final int experienceYears;
  final String username, password;

  const MechanicRegData({
    this.firstName = '', this.lastName = '',
    this.email = '', this.phone = '',
    this.location = '', this.bio = '',
    this.specialisations = const [],
    this.experienceYears = 0,
    this.username = '', this.password = '',
  });

  MechanicRegData copyWith({
    String? firstName, String? lastName, String? email,
    String? phone, String? location, String? bio,
    List<String>? specialisations, int? experienceYears,
    String? username, String? password,
  }) => MechanicRegData(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    bio: bio ?? this.bio,
    specialisations: specialisations ?? this.specialisations,
    experienceYears: experienceYears ?? this.experienceYears,
    username: username ?? this.username,
    password: password ?? this.password,
  );
}

// ── STEP 1: NAME + PHONE ─────────────────────────────────────
class MechanicRegisterScreen extends ConsumerStatefulWidget {
  const MechanicRegisterScreen({super.key});

  @override
  ConsumerState<MechanicRegisterScreen> createState() =>
      _MechanicRegisterScreenState();
}

class _MechanicRegisterScreenState
    extends ConsumerState<MechanicRegisterScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_firstCtrl.text.trim().isEmpty ||
        _lastCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MechanicRegStep2(
        data: MechanicRegData(
          firstName: _firstCtrl.text.trim(),
          lastName: _lastCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context, () => Navigator.of(context).pop()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.25),
              const SizedBox(height: 24),
              buildHeading("What's your", 'name?'),
              const SizedBox(height: 6),
              const Text('Tell us who you are.',
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_error != null) ...[
                errorBanner(_error!),
                const SizedBox(height: 16),
              ],
              AppField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstCtrl),
              const SizedBox(height: 16),
              AppField(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  controller: _lastCtrl),
              const SizedBox(height: 16),
              AppField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              primaryButton('NEXT', _next),
            ],
          ),
        ),
      ),
    );
  }
}

// ── STEP 2: EMAIL + PASSWORD ──────────────────────────────────
class MechanicRegStep2 extends StatefulWidget {
  final MechanicRegData data;
  const MechanicRegStep2({super.key, required this.data});

  @override
  State<MechanicRegStep2> createState() => _MechanicRegStep2State();
}

class _MechanicRegStep2State extends State<MechanicRegStep2> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email.');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (_passCtrl.text.length < 8) {
      setState(() =>
          _error = 'Password must be at least 8 characters.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MechanicRegStep3(
        data: widget.data.copyWith(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(
          context, () => Navigator.of(context).pop()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.50),
              const SizedBox(height: 24),
              buildHeading('Secure your', 'account.'),
              const SizedBox(height: 6),
              const Text('Your login credentials.',
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_error != null) ...[
                errorBanner(_error!),
                const SizedBox(height: 16),
              ],
              AppField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              AppField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passCtrl,
                  obscure: true),
              const SizedBox(height: 16),
              AppField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmCtrl,
                  obscure: true),
              const SizedBox(height: 32),
              primaryButton('NEXT', _next),
            ],
          ),
        ),
      ),
    );
  }
}

// ── STEP 3: LOCATION + SPECIALISATIONS + EXPERIENCE ──────────
class MechanicRegStep3 extends StatefulWidget {
  final MechanicRegData data;
  const MechanicRegStep3({super.key, required this.data});

  @override
  State<MechanicRegStep3> createState() => _MechanicRegStep3State();
}

class _MechanicRegStep3State extends State<MechanicRegStep3> {
  final _locationCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final List<String> _selected = [];
  String? _error;

  final List<String> _allSpecs = [
    'Engine Repair', 'Brake Systems', 'Electrical',
    'Transmission', 'Suspension', 'AC & Cooling',
    'Tyres & Wheels', 'Diagnostics', 'Body Work',
    'Oil & Filters', 'Exhaust', 'Fuel Systems',
  ];

  @override
  void dispose() {
    _locationCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_locationCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your location.');
      return;
    }
    if (_selected.isEmpty) {
      setState(() =>
          _error = 'Please select at least one specialisation.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MechanicRegStep4(
        data: widget.data.copyWith(
          location: _locationCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          specialisations: _selected,
          experienceYears:
              int.tryParse(_expCtrl.text.trim()) ?? 0,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(
          context, () => Navigator.of(context).pop()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.75),
              const SizedBox(height: 24),
              buildHeading('Your work', 'profile.'),
              const SizedBox(height: 6),
              const Text(
                  'Tell customers what you specialise in.',
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_error != null) ...[
                errorBanner(_error!),
                const SizedBox(height: 16),
              ],
              AppField(
                  label: 'Your Location',
                  hint: 'e.g. Ikeja, Lagos',
                  controller: _locationCtrl),
              const SizedBox(height: 16),
              AppField(
                  label: 'Years of Experience',
                  hint: 'e.g. 5',
                  controller: _expCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              AppField(
                  label: 'Short Bio (Optional)',
                  hint: 'Tell customers about yourself...',
                  controller: _bioCtrl),
              const SizedBox(height: 20),
              const Text('SPECIALISATIONS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.5,
                      fontFamily: 'Inter')),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _allSpecs.map((spec) {
                  final isSelected = _selected.contains(spec);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => isSelected
                        ? _selected.remove(spec)
                        : _selected.add(spec)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(100),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Text(spec,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontFamily: 'Inter')),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              primaryButton('NEXT', _next),
            ],
          ),
        ),
      ),
    );
  }
}

// ── STEP 4: USERNAME + FINISH ─────────────────────────────────
class MechanicRegStep4 extends StatefulWidget {
  final MechanicRegData data;
  const MechanicRegStep4({super.key, required this.data});

  @override
  State<MechanicRegStep4> createState() => _MechanicRegStep4State();
}

class _MechanicRegStep4State extends State<MechanicRegStep4> {
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_usernameCtrl.text.trim().length < 3) {
      setState(() =>
          _error = 'Username must be at least 3 characters.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = AuthService();
      AuthResponse? response;
      
      try {
        response = await authService.signUp(
          email: widget.data.email,
          password: widget.data.password,
        );
      } on AuthException catch (e) {
        // If user already exists in auth, try signing in
        final errorMsg = e.message.toLowerCase();
        if (errorMsg.contains('already') || 
            errorMsg.contains('registered') || 
            errorMsg.contains('exists') ||
            errorMsg.contains('user') ||
            errorMsg.contains('duplicate')) {
          // Account already exists, just sign in
          try {
            await authService.signIn(
              emailOrUsername: widget.data.email,
              password: widget.data.password,
            );
            // Sign in successful, proceed
          } catch (_) {
            // If sign in fails, the account might exist with different password
            setState(() => _error = 'This email is already registered with a different password. Please log in or contact support.');
            if (mounted) setState(() => _loading = false);
            return;
          }
        } else {
          setState(() => _error = formatErrorMessage(e.message));
          if (mounted) setState(() => _loading = false);
          return;
        }
      }

      // Sign in if no session yet
      if (response != null && response.session == null) {
        await authService.signIn(
          emailOrUsername: widget.data.email,
          password: widget.data.password,
        );
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Account creation failed.');

      final supabase = Supabase.instance.client;

      // Create profile with mechanic account type
      await supabase.from('profiles').upsert({
        'id': user.id,
        'first_name': widget.data.firstName,
        'last_name': widget.data.lastName,
        'email': widget.data.email,
        'phone': widget.data.phone,
        'username': _usernameCtrl.text.trim(),
        'account_type': 'mechanic',
      });

      // Create mechanic profile
      await supabase.from('mechanic_profiles').upsert({
        'id': user.id,
        'location': widget.data.location,
        'bio': widget.data.bio,
        'specialisations': widget.data.specialisations,
        'experience_years': widget.data.experienceYears,
        'is_online': false,
        'is_verified': false,
        'rating': 0.0,
        'jobs_done': 0,
        'available_balance': 0.0,
        'total_earnings': 0.0,
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => const MechanicNavigation()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = formatErrorMessage(e.message));
    } catch (e) {
      setState(() => _error =
          formatErrorMessage(e.toString().replaceAll('Exception: ', '')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(
          context, () => Navigator.of(context).pop()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(1.0),
              const SizedBox(height: 24),
              buildHeading("Almost", 'done!'),
              const SizedBox(height: 6),
              const Text('Choose your username.',
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_error != null) ...[
                errorBanner(_error!),
                const SizedBox(height: 16),
              ],
              AppField(
                  label: 'Username',
                  hint: 'Choose a unique username',
                  controller: _usernameCtrl),
              const SizedBox(height: 8),
              const Text(
                'This is how customers will find you.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              primaryButton('CREATE ACCOUNT', _createAccount,
                  isLoading: _loading),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'By creating an account, you agree to our\nTerms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


