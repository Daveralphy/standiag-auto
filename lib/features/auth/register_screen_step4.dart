import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'register_screen_step3.dart';
import '../navigation/main_navigation.dart';

class RegisterScreenStep4 extends StatefulWidget {
  const RegisterScreenStep4({super.key});

  @override
  State<RegisterScreenStep4> createState() => _RegisterScreenStep4State();
}

class _RegisterScreenStep4State extends State<RegisterScreenStep4> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 22 * s),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RegisterScreenStep3()),
              );
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32 * s, minHeight: 32 * s),
          ),
        ),
        leadingWidth: 56 * s,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              SizedBox(
                height: 4 * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2 * s),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: const Color(0xFF2A2A2E),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999),
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 28 * s),
              Text('USERNAME',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 10 * s),
              TextField(
                controller: _usernameController,
                style: TextStyle(fontSize: 16 * s, color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(
                    fontSize: 16 * s,
                    color: const Color(0xFF555555),
                    fontFamily: 'Inter',
                  ),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12 * s, right: 10 * s),
                    child: Icon(Icons.alternate_email,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 20 * s),
              Text('PASSWORD',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 10 * s),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(fontSize: 16 * s, color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    fontSize: 16 * s,
                    color: const Color(0xFF555555),
                    fontFamily: 'Inter',
                  ),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12 * s, right: 10 * s),
                    child: Icon(Icons.lock_outline,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12 * s),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF666666),
                        size: 18 * s,
                      ),
                    ),
                  ),
                  suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 20 * s),
              Text('CONFIRM PASSWORD',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 10 * s),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(fontSize: 16 * s, color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(
                    fontSize: 16 * s,
                    color: const Color(0xFF555555),
                    fontFamily: 'Inter',
                  ),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12 * s, right: 10 * s),
                    child: Icon(Icons.lock_outline,
                        color: const Color(0xFF666666), size: 18 * s),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12 * s),
                      child: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF666666),
                        size: 18 * s,
                      ),
                    ),
                  ),
                  suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              SizedBox(height: 10 * s),
              Text(
                'Your password must be at least 8 characters, include a number, and a special character.',
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32 * s),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigation(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    elevation: 0,
                  ),
                  child: Text('CREATE MY ACCOUNT',
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
