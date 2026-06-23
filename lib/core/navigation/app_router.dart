// Defines the full navigation tree for StanDiag Auto using GoRouter.
// All routes are named — never navigate with hardcoded strings.
// Screens are swapped from _PlaceholderScreen to real screens as each is built.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/mechanic_signup_step_one_screen.dart';
import '../../features/auth/screens/mechanic_signup_step_three_screen.dart';
import '../../features/auth/screens/mechanic_signup_step_two_screen.dart';
import '../../features/auth/screens/otp_email_screen.dart';
import '../../features/auth/screens/otp_phone_screen.dart';
import '../../features/auth/screens/profile_type_picker_screen.dart';
import '../../features/auth/screens/user_signup_step_one_screen.dart';
import '../../features/auth/screens/user_signup_step_three_screen.dart';
import '../../features/auth/screens/user_signup_step_two_screen.dart';
import '../../features/home/screens/mechanic_home_screen.dart';
import '../../features/home/screens/mechanic_scan_screen.dart';
import '../../features/home/screens/mechanic_users_screen.dart';
import '../../features/home/screens/user_home_screen.dart';
import '../../features/home/screens/user_mechanics_screen.dart';
import '../../features/home/screens/user_scan_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/splash_one_screen.dart';
import '../../features/onboarding/screens/splash_two_screen.dart';
import '../../shared/providers/auth_provider.dart';
import 'route_names.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String name;
  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Text(name,
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splashOne,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated = authState.valueOrNull != null;
      final bool isAuthRoute = state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.otpPhone ||
          state.matchedLocation == RouteNames.otpEmail ||
          state.matchedLocation == RouteNames.profileTypePicker ||
          state.matchedLocation == RouteNames.splashOne ||
          state.matchedLocation == RouteNames.splashTwo ||
          state.matchedLocation == RouteNames.onboarding;

      if (!isAuthenticated && !isAuthRoute) return RouteNames.login;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splashOne, builder: (_, __) => const SplashOneScreen()),
      GoRoute(path: RouteNames.splashTwo, builder: (_, __) => const SplashTwoScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: RouteNames.profileTypePicker, builder: (_, __) => const ProfileTypePickerScreen()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.otpPhone, builder: (_, __) => const OtpPhoneScreen()),
      GoRoute(path: RouteNames.otpEmail, builder: (_, __) => const OtpEmailScreen()),
      GoRoute(path: RouteNames.userSignupStepOne, builder: (_, __) => const UserSignupStepOneScreen()),
      GoRoute(path: RouteNames.userSignupStepTwo, builder: (_, __) => const UserSignupStepTwoScreen()),
      GoRoute(path: RouteNames.userSignupStepThree, builder: (_, __) => const UserSignupStepThreeScreen()),
      GoRoute(path: RouteNames.mechanicSignupStepOne, builder: (_, __) => const MechanicSignupStepOneScreen()),
      GoRoute(path: RouteNames.mechanicSignupStepTwo, builder: (_, __) => const MechanicSignupStepTwoScreen()),
      GoRoute(path: RouteNames.mechanicSignupStepThree, builder: (_, __) => const MechanicSignupStepThreeScreen()),

      // ─── User home screens ──────────────────────────────────────────────
      GoRoute(path: RouteNames.userHome, builder: (_, __) => const UserHomeScreen()),
      GoRoute(path: RouteNames.userScan, builder: (_, __) => const UserScanScreen()),
      GoRoute(path: RouteNames.userMechanics, builder: (_, __) => const UserMechanicsScreen()),

      // ─── Mechanic home screens ──────────────────────────────────────────
      GoRoute(path: RouteNames.mechanicHome, builder: (_, __) => const MechanicHomeScreen()),
      GoRoute(path: RouteNames.mechanicScan, builder: (_, __) => const MechanicScanScreen()),
      GoRoute(path: RouteNames.mechanicUsers, builder: (_, __) => const MechanicUsersScreen()),

      // ─── Placeholders ───────────────────────────────────────────────────
      GoRoute(path: RouteNames.radiusSelector, builder: (_, __) => const _PlaceholderScreen(name: 'Radius Selector')),
      GoRoute(path: RouteNames.searching, builder: (_, __) => const _PlaceholderScreen(name: 'Searching')),
      GoRoute(path: RouteNames.mechanicCard, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Card')),
      GoRoute(path: RouteNames.mechanicProfile, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Profile')),
      GoRoute(path: RouteNames.inAppCall, builder: (_, __) => const _PlaceholderScreen(name: 'In App Call')),
      GoRoute(path: RouteNames.userMechanicAccepted, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Accepted')),
      GoRoute(path: RouteNames.userTracking, builder: (_, __) => const _PlaceholderScreen(name: 'User Tracking')),
      GoRoute(path: RouteNames.userMechanicArrived, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Arrived')),
      GoRoute(path: RouteNames.userJobInProgress, builder: (_, __) => const _PlaceholderScreen(name: 'User Job In Progress')),
      GoRoute(path: RouteNames.userJobCompleted, builder: (_, __) => const _PlaceholderScreen(name: 'User Job Completed')),
      GoRoute(path: RouteNames.userRateMechanic, builder: (_, __) => const _PlaceholderScreen(name: 'Rate Mechanic')),
      GoRoute(path: RouteNames.userProfile, builder: (_, __) => const _PlaceholderScreen(name: 'User Profile')),
      GoRoute(path: RouteNames.myVehicles, builder: (_, __) => const _PlaceholderScreen(name: 'My Vehicles')),
      GoRoute(path: RouteNames.addVehicle, builder: (_, __) => const _PlaceholderScreen(name: 'Add Vehicle')),
      GoRoute(path: RouteNames.serviceHistory, builder: (_, __) => const _PlaceholderScreen(name: 'Service History')),
      GoRoute(path: RouteNames.userScanHistory, builder: (_, __) => const _PlaceholderScreen(name: 'Scan History')),
      GoRoute(path: RouteNames.userCredits, builder: (_, __) => const _PlaceholderScreen(name: 'Credits Overview')),
      GoRoute(path: RouteNames.userBuyCredits, builder: (_, __) => const _PlaceholderScreen(name: 'Buy Credits')),
      GoRoute(path: RouteNames.userCreditsHistory, builder: (_, __) => const _PlaceholderScreen(name: 'Credits History')),
      GoRoute(path: RouteNames.userSettings, builder: (_, __) => const _PlaceholderScreen(name: 'Settings')),
      GoRoute(path: RouteNames.userNotificationSettings, builder: (_, __) => const _PlaceholderScreen(name: 'Notification Settings')),
      GoRoute(path: RouteNames.userLanguage, builder: (_, __) => const _PlaceholderScreen(name: 'Language')),
      GoRoute(path: RouteNames.userAppearance, builder: (_, __) => const _PlaceholderScreen(name: 'Appearance')),
      GoRoute(path: RouteNames.userPrivacy, builder: (_, __) => const _PlaceholderScreen(name: 'Privacy')),
      GoRoute(path: RouteNames.userChangePassword, builder: (_, __) => const _PlaceholderScreen(name: 'Change Password')),
      GoRoute(path: RouteNames.userVerifyPasswordChange, builder: (_, __) => const _PlaceholderScreen(name: 'Verify Password Change')),
      GoRoute(path: RouteNames.userDeleteAccount, builder: (_, __) => const _PlaceholderScreen(name: 'Delete Account')),
      GoRoute(path: RouteNames.userHelpSupport, builder: (_, __) => const _PlaceholderScreen(name: 'Help & Support')),
      GoRoute(path: RouteNames.mechanicIncomingCall, builder: (_, __) => const _PlaceholderScreen(name: 'Incoming Call')),
      GoRoute(path: RouteNames.mechanicActiveCall, builder: (_, __) => const _PlaceholderScreen(name: 'Active Call')),
      GoRoute(path: RouteNames.mechanicPostCall, builder: (_, __) => const _PlaceholderScreen(name: 'Post Call')),
      GoRoute(path: RouteNames.mechanicEnRoute, builder: (_, __) => const _PlaceholderScreen(name: 'En Route')),
      GoRoute(path: RouteNames.mechanicJobInProgress, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Job In Progress')),
      GoRoute(path: RouteNames.mechanicJobCompleted, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Job Completed')),
      GoRoute(path: RouteNames.mechanicProfileView, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Profile View')),
      GoRoute(path: RouteNames.mechanicProfileEdit, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Profile Edit')),
      GoRoute(path: RouteNames.myJobs, builder: (_, __) => const _PlaceholderScreen(name: 'My Jobs')),
      GoRoute(path: RouteNames.jobHistory, builder: (_, __) => const _PlaceholderScreen(name: 'Job History')),
      GoRoute(path: RouteNames.mechanicCredits, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Credits')),
      GoRoute(path: RouteNames.mechanicBuyCredits, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Buy Credits')),
      GoRoute(path: RouteNames.mechanicCreditsHistory, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Credits History')),
      GoRoute(path: RouteNames.mechanicSettings, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Settings')),
      GoRoute(path: RouteNames.mechanicNotificationSettings, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Notifications')),
      GoRoute(path: RouteNames.mechanicLanguage, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Language')),
      GoRoute(path: RouteNames.mechanicAppearance, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Appearance')),
      GoRoute(path: RouteNames.mechanicPrivacy, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Privacy')),
      GoRoute(path: RouteNames.mechanicChangePassword, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Change Password')),
      GoRoute(path: RouteNames.mechanicVerifyPasswordChange, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Verify Password')),
      GoRoute(path: RouteNames.mechanicDeleteAccount, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Delete Account')),
      GoRoute(path: RouteNames.mechanicHelpSupport, builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Help & Support')),
    ],
  );
});