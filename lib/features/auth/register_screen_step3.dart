import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'register_screen_step2.dart';
import 'register_screen_step4.dart';

class RegisterScreenStep3 extends StatefulWidget {
  const RegisterScreenStep3({super.key});

  @override
  State<RegisterScreenStep3> createState() => _RegisterScreenStep3State();
}

class _RegisterScreenStep3State extends State<RegisterScreenStep3> {
  late TextEditingController _ageController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
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
                MaterialPageRoute(builder: (_) => const RegisterScreenStep2()),
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
                    value: 0.75,
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
                      text: 'Tell us a bit\n',
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
                      text: 'more about you.',
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
              Text('This helps us personalise your experience.',
                  style: TextStyle(
                    fontSize: 17 * s,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999),
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 28 * s),
              Text('GENDER',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'male';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12 * s),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'male'
                              ? AppColors.primary
                              : const Color(0xFF161619),
                          borderRadius: BorderRadius.circular(8 * s),
                          border: Border.all(
                            color: _selectedGender == 'male'
                                ? AppColors.primary
                                : const Color(0xFF2A2A2E),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.male,
                                color: _selectedGender == 'male'
                                    ? Colors.white
                                    : const Color(0xFF666666),
                                size: 18 * s),
                            SizedBox(width: 8 * s),
                            Text('Male',
                                style: TextStyle(
                                  fontSize: 15 * s,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedGender == 'male'
                                      ? Colors.white
                                      : const Color(0xFF999999),
                                  fontFamily: 'Inter',
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'female';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12 * s),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'female'
                              ? AppColors.primary
                              : const Color(0xFF161619),
                          borderRadius: BorderRadius.circular(8 * s),
                          border: Border.all(
                            color: _selectedGender == 'female'
                                ? AppColors.primary
                                : const Color(0xFF2A2A2E),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.female,
                                color: _selectedGender == 'female'
                                    ? Colors.white
                                    : const Color(0xFF666666),
                                size: 18 * s),
                            SizedBox(width: 8 * s),
                            Text('Female',
                                style: TextStyle(
                                  fontSize: 15 * s,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedGender == 'female'
                                      ? Colors.white
                                      : const Color(0xFF999999),
                                  fontFamily: 'Inter',
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'other';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12 * s),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'other'
                              ? AppColors.primary
                              : const Color(0xFF161619),
                          borderRadius: BorderRadius.circular(8 * s),
                          border: Border.all(
                            color: _selectedGender == 'other'
                                ? AppColors.primary
                                : const Color(0xFF2A2A2E),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.more_horiz,
                                color: _selectedGender == 'other'
                                    ? Colors.white
                                    : const Color(0xFF666666),
                                size: 18 * s),
                            SizedBox(width: 8 * s),
                            Text('Other',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedGender == 'other'
                                      ? Colors.white
                                      : const Color(0xFF999999),
                                  fontFamily: 'Inter',
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24 * s),
              Text('AGE',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 10 * s),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16 * s, color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your age',
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
                  suffixText: 'years old',
                  suffixStyle: TextStyle(
                    fontSize: 14 * s,
                    color: const Color(0xFF666666),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Text(
                'You must be at least 18 years old to use StanDiag.',
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreenStep4(),
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
