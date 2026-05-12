import 'package:flutter/material.dart';
import '../../core/models/register_state.dart';
import 'account_type_screen.dart';
import 'register_step_details.dart';

// Entry point for the full register flow.
// Each step pushes the next screen with updated RegisterState.
class RegisterFlow extends StatelessWidget {
  const RegisterFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountTypeScreen(
      onNext: (accountType) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => RegisterStepDetails(
            state: RegisterState(accountType: accountType),
            onNext: (state) {
              // Contact info step — coming next
              // Navigator.of(context).push(...)
            },
            onBack: () => Navigator.of(context).pop(),
          ),
        ));
      },
    );
  }
}

