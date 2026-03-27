import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/success_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/emergency_contacts_screen.dart';
import '../../features/profile/presentation/screens/expenses_screen.dart';
import '../../features/profile/presentation/screens/profile_stats_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'route_names.dart';

/// Placeholder for screens not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          name,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

GoRouter createAppRouter(ValueNotifier<bool> authStatusNotifier) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authStatusNotifier,
    redirect: (context, state) {
      final isLoggedIn = authStatusNotifier.value;
      final location = state.matchedLocation;

      // Auth-related routes (allowed without login)
      const authRoutes = [
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.auth,
        RouteNames.otp,
        RouteNames.completeProfile,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
        RouteNames.success,
      ];

      final isOnAuthRoute = authRoutes.contains(location);

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isOnAuthRoute) return RouteNames.auth;

      // Don't redirect from splash or onboarding
      if (location == RouteNames.splash ||
          location == RouteNames.onboarding) {
        return null;
      }

      // If logged in and on auth route (except success)
      if (isLoggedIn && isOnAuthRoute && location != RouteNames.success) {
        return RouteNames.main;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (_, state) {
          final args = state.extra as OtpScreenArgs;
          return OtpScreen(args: args);
        },
      ),
      GoRoute(
        path: RouteNames.completeProfile,
        builder: (_, state) {
          final args = state.extra as CompleteProfileArgs;
          return CompleteProfileScreen(args: args);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (_, state) {
          final args = state.extra as ResetPasswordArgs;
          return ResetPasswordScreen(args: args);
        },
      ),
      GoRoute(
        path: RouteNames.success,
        builder: (_, __) => const SuccessScreen(),
      ),

      // Financial routes
      GoRoute(
        path: RouteNames.settlements,
        builder: (_, __) => const _PlaceholderScreen(name: 'التسويات'),
      ),
      GoRoute(
        path: RouteNames.createSettlement,
        builder: (_, __) => const _PlaceholderScreen(name: 'تسوية جديدة'),
      ),
      GoRoute(
        path: RouteNames.detailedStats,
        builder: (_, __) => const _PlaceholderScreen(name: 'الإحصائيات'),
      ),
      GoRoute(
        path: RouteNames.paymentRequests,
        builder: (_, __) => const _PlaceholderScreen(name: 'طلبات الدفع'),
      ),
      GoRoute(
        path: RouteNames.createPaymentRequest,
        builder: (_, __) => const _PlaceholderScreen(name: 'طلب دفع جديد'),
      ),
      GoRoute(
        path: RouteNames.invoices,
        builder: (_, __) => const _PlaceholderScreen(name: 'الفواتير'),
      ),
      GoRoute(
        path: RouteNames.invoiceDetail,
        builder: (_, __) => const _PlaceholderScreen(name: 'تفاصيل الفاتورة'),
      ),

      // Main routes
      GoRoute(
        path: RouteNames.main,
        builder: (_, __) => const MainShell(),
      ),
      GoRoute(
        path: RouteNames.addOrder,
        builder: (_, __) => const _PlaceholderScreen(name: 'Add Order'),
      ),
      GoRoute(
        path: RouteNames.orderDetails,
        builder: (_, __) => const _PlaceholderScreen(name: 'Order Details'),
      ),
      GoRoute(
        path: RouteNames.completeOrder,
        builder: (_, __) => const _PlaceholderScreen(name: 'Complete Order'),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (_, __) => const _PlaceholderScreen(name: 'Profile'),
      ),

      // Profile sub-pages
      GoRoute(
        path: RouteNames.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.profileStats,
        builder: (_, __) => const ProfileStatsScreen(),
      ),
      GoRoute(
        path: RouteNames.emergencyContacts,
        builder: (_, __) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: RouteNames.profileExpenses,
        builder: (_, __) => const ExpensesScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
}
