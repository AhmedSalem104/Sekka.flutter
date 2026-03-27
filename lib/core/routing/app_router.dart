import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import 'route_names.dart';

/// Placeholder screen used before real screens are built.
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

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (_, __) => const _PlaceholderScreen(name: 'Login'),
    ),
    GoRoute(
      path: RouteNames.otp,
      builder: (_, __) => const _PlaceholderScreen(name: 'OTP'),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (_, __) => const _PlaceholderScreen(name: 'Register'),
    ),
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
  ],
);
