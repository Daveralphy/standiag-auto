// Full navigation tree for StanDiag Auto using GoRouter.

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
import '../../features/credits/screens/buy_credits_screen.dart';
import '../../features/credits/screens/credits_history_screen.dart';
import '../../features/credits/screens/credits_overview_screen.dart';
import '../../features/home/screens/mechanic_home_screen.dart';
import '../../features/home/screens/mechanic_scan_screen.dart';
import '../../features/home/screens/mechanic_users_screen.dart';
import '../../features/home/screens/user_home_screen.dart';
import '../../features/home/screens/user_mechanics_screen.dart';
import '../../features/home/screens/user_scan_screen.dart';
import '../../features/jobs/screens/mechanic_active_call_screen.dart';
import '../../features/jobs/screens/mechanic_en_route_screen.dart';
import '../../features/jobs/screens/mechanic_incoming_call_screen.dart';
import '../../features/jobs/screens/mechanic_job_completed_screen.dart';
import '../../features/jobs/screens/mechanic_job_in_progress_screen.dart';
import '../../features/jobs/screens/mechanic_post_call_screen.dart';
import '../../features/jobs/screens/user_job_completed_screen.dart';
import '../../features/jobs/screens/user_job_in_progress_screen.dart';
import '../../features/jobs/screens/user_mechanic_accepted_screen.dart';
import '../../features/jobs/screens/user_mechanic_arrived_screen.dart';
import '../../features/jobs/screens/user_rate_mechanic_screen.dart';
import '../../features/jobs/screens/user_tracking_screen.dart';
import '../../features/mechanics/screens/in_app_call_screen.dart';
import '../../features/mechanics/screens/mechanic_card_screen.dart';
import '../../features/mechanics/screens/mechanic_profile_screen.dart';
import '../../features/profile/screens/mechanic_profile_screen.dart' show MechanicProfileOwnScreen;
import '../../features/mechanics/screens/radius_selector_screen.dart';
import '../../features/mechanics/screens/searching_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/splash_one_screen.dart';
import '../../features/onboarding/screens/splash_two_screen.dart';
import '../../features/profile/screens/add_vehicle_screen.dart';
import '../../features/profile/screens/job_history_screen.dart';
import '../../features/profile/screens/mechanic_profile_edit_screen.dart';

import '../../features/profile/screens/my_jobs_screen.dart';
import '../../features/profile/screens/my_vehicles_screen.dart';
import '../../features/profile/screens/service_history_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/scan/screens/scan_history_screen.dart';
import '../../features/settings/screens/appearance_screen.dart';
import '../../features/settings/screens/change_password_screen.dart';
import '../../features/settings/screens/delete_account_screen.dart';
import '../../features/settings/screens/help_support_screen.dart';
import '../../features/settings/screens/language_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/privacy_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/verify_password_change_screen.dart';
import '../../shared/providers/auth_provider.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splashOne,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated = authState.valueOrNull != null;
      final bool isOnboardingRoute =
          state.matchedLocation == RouteNames.splashOne ||
          state.matchedLocation == RouteNames.splashTwo ||
          state.matchedLocation == RouteNames.onboarding;
      final bool isAuthRoute =
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.otpPhone ||
          state.matchedLocation == RouteNames.otpEmail ||
          state.matchedLocation == RouteNames.profileTypePicker ||
          isOnboardingRoute;

      // Authenticated user should never see onboarding or auth screens
      if (isAuthenticated && isAuthRoute) return RouteNames.userHome;

      // Unauthenticated user trying to access app screens
      if (!isAuthenticated && !isAuthRoute) return RouteNames.login;

      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splashOne, pageBuilder: (_, __) => NoTransitionPage(child: const SplashOneScreen())),
      GoRoute(path: RouteNames.splashTwo, pageBuilder: (_, __) => NoTransitionPage(child: const SplashTwoScreen())),
      GoRoute(path: RouteNames.onboarding, pageBuilder: (_, __) => NoTransitionPage(child: const OnboardingScreen())),
      GoRoute(path: RouteNames.profileTypePicker, pageBuilder: (_, __) => NoTransitionPage(child: const ProfileTypePickerScreen())),
      GoRoute(path: RouteNames.login, pageBuilder: (_, __) => NoTransitionPage(child: const LoginScreen())),
      GoRoute(path: RouteNames.otpPhone, builder: (_, __) => OtpPhoneScreen()), // ignore: prefer_const_constructors
      GoRoute(path: RouteNames.otpEmail, builder: (_, __) => OtpEmailScreen()), // ignore: prefer_const_constructors
      GoRoute(path: RouteNames.userSignupStepOne, pageBuilder: (_, __) => NoTransitionPage(child: const UserSignupStepOneScreen())),
      GoRoute(path: RouteNames.userSignupStepTwo, pageBuilder: (_, __) => NoTransitionPage(child: const UserSignupStepTwoScreen())),
      GoRoute(path: RouteNames.userSignupStepThree, pageBuilder: (_, __) => NoTransitionPage(child: const UserSignupStepThreeScreen())),
      GoRoute(path: RouteNames.mechanicSignupStepOne, pageBuilder: (_, __) => NoTransitionPage(child: const MechanicSignupStepOneScreen())),
      GoRoute(path: RouteNames.mechanicSignupStepTwo, pageBuilder: (_, __) => NoTransitionPage(child: const MechanicSignupStepTwoScreen())),
      GoRoute(path: RouteNames.mechanicSignupStepThree, pageBuilder: (_, __) => NoTransitionPage(child: const MechanicSignupStepThreeScreen())),
      GoRoute(path: RouteNames.userHome, builder: (_, __) => const UserHomeScreen()),
      GoRoute(path: RouteNames.userScan, builder: (_, __) => const UserScanScreen()),
      GoRoute(path: RouteNames.userMechanics, builder: (_, __) => const UserMechanicsScreen()),
      GoRoute(path: RouteNames.mechanicHome, builder: (_, __) => const MechanicHomeScreen()),
      GoRoute(path: RouteNames.mechanicScan, builder: (_, __) => const MechanicScanScreen()),
      GoRoute(path: RouteNames.mechanicUsers, builder: (_, __) => const MechanicUsersScreen()),
      GoRoute(path: RouteNames.radiusSelector, builder: (_, __) => const RadiusSelectorScreen()),
      GoRoute(path: RouteNames.searching, builder: (_, __) => const SearchingScreen()),
      GoRoute(path: RouteNames.mechanicCard, builder: (_, __) => const MechanicCardScreen()),
      GoRoute(path: RouteNames.mechanicProfile, builder: (_, __) => const MechanicProfileScreen()),
      GoRoute(path: RouteNames.inAppCall, builder: (_, __) => const InAppCallScreen()),
      GoRoute(path: RouteNames.mechanicIncomingCall, builder: (_, __) => const MechanicIncomingCallScreen()),
      GoRoute(path: RouteNames.mechanicActiveCall, builder: (_, __) => const MechanicActiveCallScreen()),
      GoRoute(path: RouteNames.mechanicPostCall, builder: (_, __) => const MechanicPostCallScreen()),
      GoRoute(path: RouteNames.userMechanicAccepted, builder: (_, __) => const UserMechanicAcceptedScreen()),
      GoRoute(path: RouteNames.mechanicEnRoute, builder: (_, __) => const MechanicEnRouteScreen()),
      GoRoute(path: RouteNames.userTracking, builder: (_, __) => const UserTrackingScreen()),
      GoRoute(path: RouteNames.userMechanicArrived, builder: (_, __) => const UserMechanicArrivedScreen()),
      GoRoute(path: RouteNames.userJobInProgress, builder: (_, __) => const UserJobInProgressScreen()),
      GoRoute(path: RouteNames.mechanicJobInProgress, builder: (_, __) => const MechanicJobInProgressScreen()),
      GoRoute(path: RouteNames.userJobCompleted, builder: (_, __) => const UserJobCompletedScreen()),
      GoRoute(path: RouteNames.userRateMechanic, builder: (_, __) => const UserRateMechanicScreen()),
      GoRoute(path: RouteNames.mechanicJobCompleted, builder: (_, __) => const MechanicJobCompletedScreen()),
      GoRoute(path: RouteNames.userProfile, builder: (_, __) => const UserProfileScreen()),
      GoRoute(path: RouteNames.mechanicProfileView, builder: (_, __) => const MechanicProfileOwnScreen()),
      GoRoute(path: RouteNames.mechanicProfileEdit, builder: (_, __) => const MechanicProfileEditScreen()),
      GoRoute(path: RouteNames.myVehicles, builder: (_, __) => const MyVehiclesScreen()),
      GoRoute(path: RouteNames.addVehicle, builder: (_, __) => const AddVehicleScreen()),
      GoRoute(path: RouteNames.myJobs, builder: (_, __) => const MyJobsScreen()),
      GoRoute(path: RouteNames.serviceHistory, builder: (_, __) => const ServiceHistoryScreen()),
      GoRoute(path: RouteNames.userScanHistory, builder: (_, __) => const ScanHistoryScreen()),
      GoRoute(path: RouteNames.jobHistory, builder: (_, __) => const JobHistoryScreen()),
      GoRoute(path: RouteNames.userCredits, builder: (_, __) => const CreditsOverviewScreen()),
      GoRoute(path: RouteNames.userBuyCredits, builder: (_, __) => const BuyCreditsScreen()),
      GoRoute(path: RouteNames.userCreditsHistory, builder: (_, __) => const CreditsHistoryScreen()),
      GoRoute(path: RouteNames.mechanicCredits, builder: (_, __) => const CreditsOverviewScreen()),
      GoRoute(path: RouteNames.mechanicBuyCredits, builder: (_, __) => const BuyCreditsScreen()),
      GoRoute(path: RouteNames.mechanicCreditsHistory, builder: (_, __) => const CreditsHistoryScreen()),
      GoRoute(path: RouteNames.userSettings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: RouteNames.userNotificationSettings, builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(path: RouteNames.userLanguage, builder: (_, __) => const LanguageScreen()),
      GoRoute(path: RouteNames.userAppearance, builder: (_, __) => const AppearanceScreen()),
      GoRoute(path: RouteNames.userPrivacy, builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: RouteNames.userChangePassword, builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: RouteNames.userVerifyPasswordChange, builder: (_, __) => const VerifyPasswordChangeScreen()),
      GoRoute(path: RouteNames.userDeleteAccount, builder: (_, __) => const DeleteAccountScreen()),
      GoRoute(path: RouteNames.userHelpSupport, builder: (_, __) => const HelpSupportScreen()),
      GoRoute(path: RouteNames.mechanicSettings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: RouteNames.mechanicNotificationSettings, builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(path: RouteNames.mechanicLanguage, builder: (_, __) => const LanguageScreen()),
      GoRoute(path: RouteNames.mechanicAppearance, builder: (_, __) => const AppearanceScreen()),
      GoRoute(path: RouteNames.mechanicPrivacy, builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: RouteNames.mechanicChangePassword, builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: RouteNames.mechanicVerifyPasswordChange, builder: (_, __) => const VerifyPasswordChangeScreen()),
      GoRoute(path: RouteNames.mechanicDeleteAccount, builder: (_, __) => const DeleteAccountScreen()),
      GoRoute(path: RouteNames.mechanicHelpSupport, builder: (_, __) => const HelpSupportScreen()),
    ],
  );
});