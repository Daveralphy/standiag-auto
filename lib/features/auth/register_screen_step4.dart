import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import 'register_screen_step3.dart';
import '../vehicle/first_vehicle_screen.dart';

class RegisterScreenStep4 extends ConsumerStatefulWidget {
  const RegisterScreenStep4({super.key});

  @override
  ConsumerState<RegisterScreenStep4> createState() =>
      _RegisterScreenStep4State();
}

class _RegisterScreenStep4State
    extends ConsumerState<RegisterScreenStep4> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      setState(() => _errorMessage = 'Please enter a username.');
      return;
    }
    if (username.length < 3) {
      setState(
          () => _errorMessage = 'Username must be at least 3 characters.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a password.');
      return;
    }
    if (password.length < 8) {
      setState(() =>
          _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final regData = ref.read(registrationProvider);
      final authService = AuthService();

      // 1. Create Supabase auth user
      final response = await authService.signUp(
        email: regData.email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        setState(() => _errorMessage =
            'Account creation failed. Please try again.');
        return;
      }
      // Sign in immediately after signup (works when email confirm is off)
      if (response.session == null) {
        await authService.signIn(
          emailOrUsername: regData.email,
          password: password,
        );
      }

      // 2. Create profile record
      await authService.createProfile(
        userId: user.id,
        email: regData.email,
        firstName: regData.firstName,
        lastName: regData.lastName,
        username: username,
        phone: '\\',
        gender: regData.gender,
        age: regData.age,
      );

      // 3. Create welcome notification
      await NotificationService().createWelcomeNotification(user.id);

      // 4. Clear registration state
      ref.read(registrationProvider.notifier).reset();

      // 5. Navigate to main app
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const FirstVehicleScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() =>
          _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = sw / 430;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16 * s),
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white, size: 22 * s),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => const RegisterScreenStep3()),
            ),
            padding: EdgeInsets.zero,
            constraints:
                BoxConstraints(minWidth: 32 * s, minHeight: 32 * s),
          ),
        ),
        leadingWidth: 56 * s,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4 * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2 * s),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: const Color(0xFF2A2A2E),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 20 * s),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Secure your\n',
                      style: TextStyle(
                        fontSize: 40 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    TextSpan(
                      text: 'account.',
                      style: TextStyle(
                        fontSize: 40 * s,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontFamily: 'Inter',
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * s),
              Text('Choose a username and a strong password.',
                  style: TextStyle(
                    fontSize: 17 * s,
                    color: const Color(0xFF999999),
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 28 * s),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    color: AppColors.criticalBg,
                    borderRadius: BorderRadius.circular(8 * s),
                    border: Border.all(color: AppColors.criticalBorder),
                  ),
                  child: Text(_errorMessage!,
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: AppColors.primaryLight,
                        fontFamily: 'Inter',
                      )),
                ),
                SizedBox(height: 16 * s),
              ],

              Text('USERNAME',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _usernameController,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(
                      fontSize: 16 * s,
                      color: const Color(0xFF555555),
                      fontFamily: 'Inter'),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16 * s, vertical: 16 * s),
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(left: 12 * s, right: 10 * s),
                    child: Icon(Icons.alternate_email,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 20 * s),
              Text('PASSWORD',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                      fontSize: 16 * s,
                      color: const Color(0xFF555555),
                      fontFamily: 'Inter'),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16 * s, vertical: 16 * s),
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(left: 12 * s, right: 10 * s),
                    child: Icon(Icons.lock_outline,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                    child: Padding(
                      padding: EdgeInsets.only(right: 12 * s),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF666666),
                        size: 18 * s,
                      ),
                    ),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 20 * s),
              Text('CONFIRM PASSWORD',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(
                      fontSize: 16 * s,
                      color: const Color(0xFF555555),
                      fontFamily: 'Inter'),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16 * s, vertical: 16 * s),
                  prefixIcon: Padding(
                    padding:
                        EdgeInsets.only(left: 12 * s, right: 10 * s),
                    child: Icon(Icons.lock_outline,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() =>
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword),
                    child: Padding(
                      padding: EdgeInsets.only(right: 12 * s),
                      child: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF666666),
                        size: 18 * s,
                      ),
                    ),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 10 * s),
              Text(
                'Your password must be at least 8 characters, include a number, and a special character.',
                style: TextStyle(
                  fontSize: 13 * s,
                  color: const Color(0xFF666666),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32 * s),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20 * s,
                          width: 20 * s,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('CREATE MY ACCOUNT',
                          style: TextStyle(
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            fontFamily: 'Inter',
                          )),
                ),
              ),
              SizedBox(height: 16 * s),
              Center(
                child: Text(
                  'I agree to StanDiag Terms of Service\nand Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11 * s,
                    color: const Color(0xFF666666),
                    fontFamily: 'Inter',
                    height: 1.4,
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






