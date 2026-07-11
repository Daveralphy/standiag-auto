// Full navigation tree for StanDiag Auto using GoRouter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
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
import '../../features/mechanics/screens/mechanic_candidate_profile_screen.dart';
import '../../features/mechanics/screens/mechanic_card_screen.dart';
import '../../features/profile/screens/mechanic_profile_screen.dart';
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
import '../../shared/providers/user_provider.dart';
import 'route_names.dart';

// Bridges Riverpod's auth state to GoRouter's Listenable-based refresh hook,
// so the router re-evaluates `redirect` the moment auth state changes (e.g.
// on sign-out) instead of only on the next manual navigation.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// A quick fade + gentle upward drift, used for the home-tab destinations
// (Home/Scan/Mechanics or Users on each side) so both arriving fresh from
// login and switching between tabs feel like one smooth motion instead of
// an abrupt jump cut, without being slow enough to feel laggy.
CustomTransitionPage _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen(authStateProvider, (_, __) => refreshNotifier.notify());
  ref.listen(currentUserTypeProvider, (_, __) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splashOne,
    refreshListenable: refreshNotifier,
        redirect: (_, state) {
            final location = state.matchedLocation;
            const publicRoutes = {
                RouteNames.splashOne,
                RouteNames.splashTwo,
                RouteNames.onboarding,
                RouteNames.profileTypePicker,
                RouteNames.login,
                RouteNames.forgotPassword,
                RouteNames.otpPhone,
                RouteNames.otpEmail,
                RouteNames.userSignupStepOne,
                RouteNames.userSignupStepTwo,
                RouteNames.userSignupStepThree,
                RouteNames.mechanicSignupStepOne,
                RouteNames.mechanicSignupStepTwo,
                RouteNames.mechanicSignupStepThree,
            };

            // Use `read`, not `watch`: this callback re-runs on every
            // navigation attempt and on the refreshListenable above, so
            // watching here would rebuild this whole GoRouter (and reset
            // navigation state) on every auth/profile change instead of
            // just re-evaluating the redirect.
            final isAuthenticated = ref.read(currentUserProvider) != null;
            if (!isAuthenticated) {
                return publicRoutes.contains(location) ? null : RouteNames.login;
            }

            // Keep each profile type inside its own route tree — a Mechanic
            // account has no business on `/user/...` routes and vice versa.
            final type = ref.read(currentUserTypeProvider);
            final onMechanicRoute = location.startsWith('/mechanic/');
            final onUserRoute = location.startsWith('/user/');
            if (type == UserType.mechanic && onUserRoute) {
                return RouteNames.mechanicHome;
            }
            if (type == UserType.carOwner && onMechanicRoute) {
                return RouteNames.userHome;
            }

            return null;
        },
    routes: [
      GoRoute(
        path: RouteNames.splashOne,
        pageBuilder: (_, __) =>
        const NoTransitionPage(child: SplashOneScreen()),
      ),
      GoRoute(
        path: RouteNames.splashTwo,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: SplashTwoScreen()),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: RouteNames.profileTypePicker,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: ProfileTypePickerScreen()),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.otpPhone,
        builder: (_, __) => OtpPhoneScreen(), // ignore: prefer_const_constructors
      ),
      GoRoute(
        path: RouteNames.otpEmail,
        builder: (_, __) => OtpEmailScreen(), // ignore: prefer_const_constructors
      ),
      GoRoute(
        path: RouteNames.userSignupStepOne,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: UserSignupStepOneScreen()),
      ),
      GoRoute(
        path: RouteNames.userSignupStepTwo,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: UserSignupStepTwoScreen()),
      ),
      GoRoute(
        path: RouteNames.userSignupStepThree,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: UserSignupStepThreeScreen()),
      ),
      GoRoute(
        path: RouteNames.mechanicSignupStepOne,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MechanicSignupStepOneScreen()),
      ),
      GoRoute(
        path: RouteNames.mechanicSignupStepTwo,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MechanicSignupStepTwoScreen()),
      ),
      GoRoute(
        path: RouteNames.mechanicSignupStepThree,
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MechanicSignupStepThreeScreen()),
      ),
      GoRoute(path: RouteNames.userHome,
          pageBuilder: (_, state) => _fadePage(const UserHomeScreen(), state)),
      GoRoute(path: RouteNames.userScan,
          pageBuilder: (_, state) => _fadePage(const UserScanScreen(), state)),
      GoRoute(path: RouteNames.userMechanics,
          pageBuilder: (_, state) => _fadePage(const UserMechanicsScreen(), state)),
      GoRoute(path: RouteNames.mechanicHome,
          pageBuilder: (_, state) => _fadePage(const MechanicHomeScreen(), state)),
      GoRoute(path: RouteNames.mechanicScan,
          pageBuilder: (_, state) => _fadePage(const MechanicScanScreen(), state)),
      GoRoute(path: RouteNames.mechanicUsers,
          pageBuilder: (_, state) => _fadePage(const MechanicUsersScreen(), state)),

      GoRoute(path: RouteNames.radiusSelector,
          builder: (_, __) => const RadiusSelectorScreen()),
      GoRoute(path: RouteNames.searching,
          builder: (_, state) =>
              SearchingScreen(radiusKm: state.extra as double? ?? 5.0)),
      GoRoute(path: RouteNames.mechanicCard,
          builder: (_, state) =>
              MechanicCardScreen(mechanicId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.mechanicProfile,
          builder: (_, state) => MechanicCandidateProfileScreen(
              mechanicId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.inAppCall,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            return InAppCallScreen(
              jobId: extra['jobId'] as String? ?? '',
              mechanicId: extra['mechanicId'] as String? ?? '',
            );
          }),
      GoRoute(path: RouteNames.mechanicIncomingCall,
          builder: (_, state) =>
              MechanicIncomingCallScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.mechanicActiveCall,
          builder: (_, state) =>
              MechanicActiveCallScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.mechanicPostCall,
          builder: (_, state) =>
              MechanicPostCallScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userMechanicAccepted,
          builder: (_, state) =>
              UserMechanicAcceptedScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.mechanicEnRoute,
          builder: (_, state) =>
              MechanicEnRouteScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userTracking,
          builder: (_, state) =>
              UserTrackingScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userMechanicArrived,
          builder: (_, state) =>
              UserMechanicArrivedScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userJobInProgress,
          builder: (_, state) =>
              UserJobInProgressScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.mechanicJobInProgress,
          builder: (_, state) =>
              MechanicJobInProgressScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userJobCompleted,
          builder: (_, state) =>
              UserJobCompletedScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userRateMechanic,
          builder: (_, state) =>
              UserRateMechanicScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.mechanicJobCompleted,
          builder: (_, state) =>
              MechanicJobCompletedScreen(jobId: state.extra as String? ?? '')),
      GoRoute(path: RouteNames.userProfile,
          builder: (_, __) => const UserProfileScreen()),
      GoRoute(path: RouteNames.mechanicProfileView,
          builder: (_, __) => const MechanicProfileOwnScreen()),
      GoRoute(path: RouteNames.mechanicProfileEdit,
          builder: (_, __) => const MechanicProfileEditScreen()),
      GoRoute(path: RouteNames.myVehicles,
          builder: (_, __) => const MyVehiclesScreen()),
      GoRoute(path: RouteNames.addVehicle,
          builder: (_, __) => const AddVehicleScreen()),
      GoRoute(path: RouteNames.myJobs,
          builder: (_, __) => const MyJobsScreen()),
      GoRoute(path: RouteNames.serviceHistory,
          builder: (_, __) => const ServiceHistoryScreen()),
      GoRoute(path: RouteNames.userScanHistory,
          builder: (_, __) => const ScanHistoryScreen()),
      GoRoute(path: RouteNames.jobHistory,
          builder: (_, __) => const JobHistoryScreen()),
      GoRoute(path: RouteNames.userCredits,
          builder: (_, __) => const CreditsOverviewScreen()),
      GoRoute(path: RouteNames.userBuyCredits,
          builder: (_, __) => const BuyCreditsScreen()),
      GoRoute(path: RouteNames.userCreditsHistory,
          builder: (_, __) => const CreditsHistoryScreen()),
      GoRoute(path: RouteNames.mechanicCredits,
          builder: (_, __) => const CreditsOverviewScreen()),
      GoRoute(path: RouteNames.mechanicBuyCredits,
          builder: (_, __) => const BuyCreditsScreen()),
      GoRoute(path: RouteNames.mechanicCreditsHistory,
          builder: (_, __) => const CreditsHistoryScreen()),
      GoRoute(path: RouteNames.userSettings,
          builder: (_, __) => const SettingsScreen()),
      GoRoute(path: RouteNames.userNotificationSettings,
          builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(path: RouteNames.userLanguage,
          builder: (_, __) => const LanguageScreen()),
      GoRoute(path: RouteNames.userAppearance,
          builder: (_, __) => const AppearanceScreen()),
      GoRoute(path: RouteNames.userPrivacy,
          builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: RouteNames.userChangePassword,
          builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: RouteNames.userVerifyPasswordChange,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            return VerifyPasswordChangeScreen(
              currentPassword: extra['current'] as String? ?? '',
              newPassword: extra['new'] as String? ?? '',
            );
          }),
      GoRoute(path: RouteNames.userDeleteAccount,
          builder: (_, __) => const DeleteAccountScreen()),
      GoRoute(path: RouteNames.userHelpSupport,
          builder: (_, __) => const HelpSupportScreen()),
      GoRoute(path: RouteNames.mechanicSettings,
          builder: (_, __) => const SettingsScreen()),
      GoRoute(path: RouteNames.mechanicNotificationSettings,
          builder: (_, __) => const NotificationSettingsScreen()),
      GoRoute(path: RouteNames.mechanicLanguage,
          builder: (_, __) => const LanguageScreen()),
      GoRoute(path: RouteNames.mechanicAppearance,
          builder: (_, __) => const AppearanceScreen()),
      GoRoute(path: RouteNames.mechanicPrivacy,
          builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: RouteNames.mechanicChangePassword,
          builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: RouteNames.mechanicVerifyPasswordChange,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            return VerifyPasswordChangeScreen(
              currentPassword: extra['current'] as String? ?? '',
              newPassword: extra['new'] as String? ?? '',
            );
          }),
      GoRoute(path: RouteNames.mechanicDeleteAccount,
          builder: (_, __) => const DeleteAccountScreen()),
      GoRoute(path: RouteNames.mechanicHelpSupport,
          builder: (_, __) => const HelpSupportScreen()),
    ],
  );
});