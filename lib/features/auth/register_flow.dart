import 'package:flutter/material.dart';
import '../../core/models/register_state.dart';
import 'account_type_screen.dart';
import 'register_step_details.dart';
import '../navigation/main_navigation.dart';
import '../mechanic/mechanic_navigation.dart';

// Entry point for the full register flow.
// Each step pushes the next via Navigator; identity calls onSuccess
// which replaces the entire stack with the appropriate home screen.
class RegisterFlow extends StatelessWidget {
  const RegisterFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountTypeScreen(
      onNext: (accountType) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => RegisterStepDetails(
            state: RegisterState(accountType: accountType),
            onNext: (state) => _onRegistered(context, state),
            onBack: () => Navigator.of(context).pop(),
          ),
        ));
      },
    );
  }

  void _onRegistered(BuildContext context, RegisterState state) {
    // Replace entire stack with the correct home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => state.accountType == 'mechanic'
            ? const MechanicNavigation()
            : const MainNavigation(),
      ),
      (_) => false,
    );
  }
}