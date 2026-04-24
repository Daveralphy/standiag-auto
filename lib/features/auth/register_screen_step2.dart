import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import 'register_screen.dart';
import 'register_screen_step3.dart';

class RegisterScreenStep2 extends ConsumerStatefulWidget {
  const RegisterScreenStep2({super.key});

  @override
  ConsumerState<RegisterScreenStep2> createState() =>
      _RegisterScreenStep2State();
}

class _RegisterScreenStep2State
    extends ConsumerState<RegisterScreenStep2> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedCountry = '+234';
  String? _errorMessage;

  final List<String> _countryCodes = [
    '+234', '+1', '+44', '+91', '+86', '+81', '+33', '+49', '+27',
    '+254', '+233', '+225',
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _next() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    ref
        .read(registrationProvider.notifier)
        .setStep2(email, phone, _selectedCountry);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreenStep3()),
    );
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
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
                    value: 0.50,
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
                      text: 'How do we\n',
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
                      text: 'reach you?',
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
              Text("We'll never share your contact details.",
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

              Text('EMAIL ADDRESS',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
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
                    child: Icon(Icons.email_outlined,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 20 * s),
              Text('PHONE NUMBER',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161619),
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12 * s),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        dropdownColor: const Color(0xFF2A2A2E),
                        style: TextStyle(
                          fontSize: 15 * s,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedCountry = v);
                          }
                        },
                        items: _countryCodes
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          fontSize: 16 * s,
                          color: Colors.white,
                          fontFamily: 'Inter'),
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
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
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * s),
              Text(
                'Your phone number is used for account recovery.',
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
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    elevation: 0,
                  ),
                  child: Text('CONTINUE',
                      style: TextStyle(
                        fontSize: 17 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter',
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
