import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'register_screen.dart';
import '../navigation/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = sw / 430;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20 * s, 32 * s, 20 * s, 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Text('Welcome back.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    height: 1.2,
                    letterSpacing: -0.4,
                  )),
              SizedBox(height: 8 * s),
              Text('Sign in to your StanDiag account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17 * s,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999),
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 32 * s),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMAIL ADDRESS',
                        style: TextStyle(
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF999999),
                          letterSpacing: 0.3,
                          fontFamily: 'Inter',
                        )),
                    SizedBox(height: 10 * s),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 16 * s, color: Colors.white, fontFamily: 'Inter'),
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
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
                      obscureText: true,
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
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Forgot your password?',
                            style: TextStyle(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              fontFamily: 'Inter',
                            )),
                      ),
                    ),
                    SizedBox(height: 28 * s),
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
                        child: Text('SIGN IN',
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
              SizedBox(height: 20 * s),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: const Color(0xFF2A2A2E),
                          height: 1,
                          thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s),
                    child: Text('or',
                        style: TextStyle(
                          fontSize: 15 * s,
                          color: const Color(0xFF666666),
                          fontFamily: 'Inter',
                        )),
                  ),
                  Expanded(
                      child: Divider(
                          color: const Color(0xFF2A2A2E),
                          height: 1,
                          thickness: 1)),
                ],
              ),
              SizedBox(height: 20 * s),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainNavigation(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14 * s),
                    side: const BorderSide(
                      color: Color(0xFF2A2A2E),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                  ),
                  child: Text('Continue with Google',
                      style: TextStyle(
                        fontSize: 17 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      )),
                ),
              ),
              SizedBox(height: 24 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account yet? ',
                      style: TextStyle(
                        fontSize: 15 * s,
                        color: const Color(0xFF999999),
                        fontFamily: 'Inter',
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text('Create an account',
                        style: TextStyle(
                            fontSize: 15 * s,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        )),
                  ),
                ],
              ),
              SizedBox(height: 20 * s),
              Text(
                'By signing in, you agree to our\nTerms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13 * s,
                  color: const Color(0xFF666666),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
