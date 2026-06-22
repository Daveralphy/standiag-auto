// Defines the full navigation tree for StanDiag Auto using GoRouter.
// All routes are named — never navigate with hardcoded strings.
// The router watches Firebase Auth state to redirect unauthenticated users.
//
// IMPORTANT: Screen imports are currently stubbed with _PlaceholderScreen.
// Replace each placeholder with the real screen import as screens are built.
// Never remove a route — only replace its builder.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/auth_provider.dart';
import 'route_names.dart';

// ─── Placeholder ────────────────────────────────────────────────────────────
// Temporary screen shown for routes whose real screen has not been built yet.
// Replace this with the actual screen import + class as each screen is built.
class _PlaceholderScreen extends StatelessWidget {
  final String name;
  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Text(
          name,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }
}

// ─── Router Provider ────────────────────────────────────────────────────────

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
      // ─── App Entry ──────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splashOne,
        builder: (_, __) => const _PlaceholderScreen(name: 'Splash One'),
      ),
      GoRoute(
        path: RouteNames.splashTwo,
        builder: (_, __) => const _PlaceholderScreen(name: 'Splash Two'),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const _PlaceholderScreen(name: 'Onboarding'),
      ),
      GoRoute(
        path: RouteNames.profileTypePicker,
        builder: (_, __) => const _PlaceholderScreen(name: 'Profile Type Picker'),
      ),

      // ─── Authentication ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const _PlaceholderScreen(name: 'Login'),
      ),
      GoRoute(
        path: RouteNames.otpPhone,
        builder: (_, __) => const _PlaceholderScreen(name: 'OTP Phone'),
      ),
      GoRoute(
        path: RouteNames.otpEmail,
        builder: (_, __) => const _PlaceholderScreen(name: 'OTP Email'),
      ),
      GoRoute(
        path: RouteNames.userSignupStepOne,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Signup Step 1'),
      ),
      GoRoute(
        path: RouteNames.userSignupStepTwo,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Signup Step 2'),
      ),
      GoRoute(
        path: RouteNames.userSignupStepThree,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Signup Step 3'),
      ),
      GoRoute(
        path: RouteNames.mechanicSignupStepOne,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Signup Step 1'),
      ),
      GoRoute(
        path: RouteNames.mechanicSignupStepTwo,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Signup Step 2'),
      ),
      GoRoute(
        path: RouteNames.mechanicSignupStepThree,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Signup Step 3'),
      ),

      // ─── User Screens ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.userHome,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Home'),
      ),
      GoRoute(
        path: RouteNames.userScan,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Scan'),
      ),
      GoRoute(
        path: RouteNames.userMechanics,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Mechanics'),
      ),
      GoRoute(
        path: RouteNames.radiusSelector,
        builder: (_, __) => const _PlaceholderScreen(name: 'Radius Selector'),
      ),
      GoRoute(
        path: RouteNames.searching,
        builder: (_, __) => const _PlaceholderScreen(name: 'Searching'),
      ),
      GoRoute(
        path: RouteNames.mechanicCard,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Card'),
      ),
      GoRoute(
        path: RouteNames.mechanicProfile,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Profile'),
      ),
      GoRoute(
        path: RouteNames.inAppCall,
        builder: (_, __) => const _PlaceholderScreen(name: 'In App Call'),
      ),
      GoRoute(
        path: RouteNames.userMechanicAccepted,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Accepted'),
      ),
      GoRoute(
        path: RouteNames.userTracking,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Tracking'),
      ),
      GoRoute(
        path: RouteNames.userMechanicArrived,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Arrived'),
      ),
      GoRoute(
        path: RouteNames.userJobInProgress,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Job In Progress'),
      ),
      GoRoute(
        path: RouteNames.userJobCompleted,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Job Completed'),
      ),
      GoRoute(
        path: RouteNames.userRateMechanic,
        builder: (_, __) => const _PlaceholderScreen(name: 'Rate Mechanic'),
      ),
      GoRoute(
        path: RouteNames.userProfile,
        builder: (_, __) => const _PlaceholderScreen(name: 'User Profile'),
      ),
      GoRoute(
        path: RouteNames.myVehicles,
        builder: (_, __) => const _PlaceholderScreen(name: 'My Vehicles'),
      ),
      GoRoute(
        path: RouteNames.addVehicle,
        builder: (_, __) => const _PlaceholderScreen(name: 'Add Vehicle'),
      ),
      GoRoute(
        path: RouteNames.serviceHistory,
        builder: (_, __) => const _PlaceholderScreen(name: 'Service History'),
      ),
      GoRoute(
        path: RouteNames.userScanHistory,
        builder: (_, __) => const _PlaceholderScreen(name: 'Scan History'),
      ),
      GoRoute(
        path: RouteNames.userCredits,
        builder: (_, __) => const _PlaceholderScreen(name: 'Credits Overview'),
      ),
      GoRoute(
        path: RouteNames.userBuyCredits,
        builder: (_, __) => const _PlaceholderScreen(name: 'Buy Credits'),
      ),
      GoRoute(
        path: RouteNames.userCreditsHistory,
        builder: (_, __) => const _PlaceholderScreen(name: 'Credits History'),
      ),
      GoRoute(
        path: RouteNames.userSettings,
        builder: (_, __) => const _PlaceholderScreen(name: 'Settings'),
      ),
      GoRoute(
        path: RouteNames.userNotificationSettings,
        builder: (_, __) => const _PlaceholderScreen(name: 'Notification Settings'),
      ),
      GoRoute(
        path: RouteNames.userLanguage,
        builder: (_, __) => const _PlaceholderScreen(name: 'Language'),
      ),
      GoRoute(
        path: RouteNames.userAppearance,
        builder: (_, __) => const _PlaceholderScreen(name: 'Appearance'),
      ),
      GoRoute(
        path: RouteNames.userPrivacy,
        builder: (_, __) => const _PlaceholderScreen(name: 'Privacy'),
      ),
      GoRoute(
        path: RouteNames.userChangePassword,
        builder: (_, __) => const _PlaceholderScreen(name: 'Change Password'),
      ),
      GoRoute(
        path: RouteNames.userVerifyPasswordChange,
        builder: (_, __) => const _PlaceholderScreen(name: 'Verify Password Change'),
      ),
      GoRoute(
        path: RouteNames.userDeleteAccount,
        builder: (_, __) => const _PlaceholderScreen(name: 'Delete Account'),
      ),
      GoRoute(
        path: RouteNames.userHelpSupport,
        builder: (_, __) => const _PlaceholderScreen(name: 'Help & Support'),
      ),

      // ─── Mechanic Screens ────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.mechanicHome,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Home'),
      ),
      GoRoute(
        path: RouteNames.mechanicScan,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Scan'),
      ),
      GoRoute(
        path: RouteNames.mechanicUsers,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Users'),
      ),
      GoRoute(
        path: RouteNames.mechanicIncomingCall,
        builder: (_, __) => const _PlaceholderScreen(name: 'Incoming Call'),
      ),
      GoRoute(
        path: RouteNames.mechanicActiveCall,
        builder: (_, __) => const _PlaceholderScreen(name: 'Active Call'),
      ),
      GoRoute(
        path: RouteNames.mechanicPostCall,
        builder: (_, __) => const _PlaceholderScreen(name: 'Post Call'),
      ),
      GoRoute(
        path: RouteNames.mechanicEnRoute,
        builder: (_, __) => const _PlaceholderScreen(name: 'En Route'),
      ),
      GoRoute(
        path: RouteNames.mechanicJobInProgress,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Job In Progress'),
      ),
      GoRoute(
        path: RouteNames.mechanicJobCompleted,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Job Completed'),
      ),
      GoRoute(
        path: RouteNames.mechanicProfileView,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Profile View'),
      ),
      GoRoute(
        path: RouteNames.mechanicProfileEdit,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Profile Edit'),
      ),
      GoRoute(
        path: RouteNames.myJobs,
        builder: (_, __) => const _PlaceholderScreen(name: 'My Jobs'),
      ),
      GoRoute(
        path: RouteNames.jobHistory,
        builder: (_, __) => const _PlaceholderScreen(name: 'Job History'),
      ),
      GoRoute(
        path: RouteNames.mechanicCredits,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Credits'),
      ),
      GoRoute(
        path: RouteNames.mechanicBuyCredits,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Buy Credits'),
      ),
      GoRoute(
        path: RouteNames.mechanicCreditsHistory,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Credits History'),
      ),
      GoRoute(
        path: RouteNames.mechanicSettings,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Settings'),
      ),
      GoRoute(
        path: RouteNames.mechanicNotificationSettings,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Notifications'),
      ),
      GoRoute(
        path: RouteNames.mechanicLanguage,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Language'),
      ),
      GoRoute(
        path: RouteNames.mechanicAppearance,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Appearance'),
      ),
      GoRoute(
        path: RouteNames.mechanicPrivacy,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Privacy'),
      ),
      GoRoute(
        path: RouteNames.mechanicChangePassword,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Change Password'),
      ),
      GoRoute(
        path: RouteNames.mechanicVerifyPasswordChange,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Verify Password'),
      ),
      GoRoute(
        path: RouteNames.mechanicDeleteAccount,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Delete Account'),
      ),
      GoRoute(
        path: RouteNames.mechanicHelpSupport,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mechanic Help & Support'),
      ),
    ],
  );
});