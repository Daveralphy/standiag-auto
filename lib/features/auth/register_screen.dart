import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen_step2.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _next() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }

    ref.read(registrationProvider.notifier).setStep1(firstName, lastName);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreenStep2()),
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
              MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                    value: 0.25,
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
                      text: "What's your\n",
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
                      text: 'name?',
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
              Text("This is how you'll appear on your account.",
                  style: TextStyle(
                    fontSize: 17 * s,
                    fontWeight: FontWeight.w400,
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

              Text('FIRST NAME',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _firstNameController,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
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
                    child: Icon(Icons.person_outline,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 16 * s),
              Text('LAST NAME',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _lastNameController,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
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
                    child: Icon(Icons.person_outline,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 10 * s),
              Text(
                "Use the name on your official ID. You can't change this later without approval.",
                style: TextStyle(
                  fontSize: 14 * s,
                  color: const Color(0xFF666666),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24 * s),
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
                  child: Text('NEXT',
                      style: TextStyle(
                        fontSize: 15 * s,
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
