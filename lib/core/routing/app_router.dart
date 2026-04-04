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
import '../../features/customers/presentation/screens/customers_list_screen.dart';
import '../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../features/partners/presentation/screens/partners_list_screen.dart';
import '../../features/partners/presentation/screens/partner_detail_screen.dart';
import '../../features/partners/data/models/partner_model.dart';
import '../../features/settlements/presentation/screens/settlements_screen.dart';
import '../../features/settlements/presentation/screens/create_settlement_screen.dart';
import '../../features/settlements/presentation/screens/partner_settlement_detail_screen.dart';
import '../../features/statistics/data/datasources/statistics_remote_datasource.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/orders/presentation/screens/create_order_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/emergency_contacts_screen.dart';
import '../../features/profile/presentation/screens/expenses_screen.dart';
import '../../features/profile/presentation/screens/profile_stats_screen.dart';
import '../../features/privacy/data/datasources/privacy_remote_datasource.dart';
import '../../features/privacy/data/repositories/privacy_repository_impl.dart';
import '../../features/privacy/presentation/bloc/privacy_bloc.dart';
import '../../features/privacy/presentation/screens/privacy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shifts/presentation/screens/shift_summary_screen.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/conversations_bloc.dart';
import '../../features/chat/presentation/bloc/conversations_event.dart';
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/sos/data/repositories/sos_repository.dart';
import '../../features/sos/presentation/screens/sos_history_screen.dart';
import '../../features/invoices/data/datasources/invoice_remote_datasource.dart';
import '../../features/invoices/data/repositories/invoice_repository_impl.dart';
import '../../features/invoices/presentation/bloc/invoices_bloc.dart';
import '../../features/invoices/presentation/bloc/invoices_event.dart';
import '../../features/invoices/presentation/screens/invoices_list_screen.dart';
import '../../features/badge/data/repositories/badge_repository.dart';
import '../../features/badge/presentation/bloc/badge_bloc.dart';
import '../../features/badge/presentation/bloc/badge_event.dart';
import '../../features/badge/presentation/screens/badge_screen.dart';
import '../../features/gamification/data/repositories/gamification_repository.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';
import '../../features/gamification/presentation/bloc/gamification_event.dart';
import '../../features/gamification/presentation/screens/gamification_screen.dart';
import '../../shared/network/dio_client.dart';
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
        builder: (_, __) => const SettlementsScreen(),
      ),
      GoRoute(
        path: RouteNames.createSettlement,
        builder: (_, state) {
          final partner = state.extra as PartnerModel?;
          return CreateSettlementScreen(preselectedPartner: partner);
        },
      ),
      GoRoute(
        path: RouteNames.partnerSettlementDetail,
        builder: (_, state) {
          final partner = state.extra! as PartnerModel;
          return PartnerSettlementDetailScreen(partner: partner);
        },
      ),
      GoRoute(
        path: RouteNames.detailedStats,
        builder: (context, __) {
          final dioClient = context.read<DioClient>();
          final dataSource = StatisticsRemoteDataSource(dioClient);
          final repository = StatisticsRepositoryImpl(
            remoteDataSource: dataSource,
          );
          return BlocProvider(
            create: (_) {
              final bloc = StatisticsBloc(repository: repository);
              if (bloc.state is! StatisticsLoaded) {
                bloc.add(const StatisticsTabChanged(StatisticsTab.weekly));
              }
              return bloc;
            },
            child: const StatisticsScreen(),
          );
        },
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
        builder: (context, __) {
          final dioClient = context.read<DioClient>();
          final dataSource = InvoiceRemoteDataSource(dioClient);
          final repository =
              InvoiceRepositoryImpl(remoteDataSource: dataSource);
          return BlocProvider(
            create: (_) => InvoicesBloc(repository: repository)
              ..add(const InvoicesLoadRequested()),
            child: const InvoicesListScreen(),
          );
        },
      ),

      // Main routes
      GoRoute(
        path: RouteNames.main,
        builder: (_, __) => const MainShell(),
      ),
      GoRoute(
        path: RouteNames.addOrder,
        builder: (_, __) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: RouteNames.orderDetails,
        builder: (_, state) {
          final orderId = state.extra as String;
          return OrderDetailScreen(orderId: orderId);
        },
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
      GoRoute(
        path: RouteNames.shiftSummary,
        builder: (_, __) => const ShiftSummaryScreen(),
      ),
      GoRoute(
        path: RouteNames.privacy,
        builder: (context, __) {
          final dioClient = context.read<DioClient>();
          final dataSource = PrivacyRemoteDataSource(dioClient);
          final repository = PrivacyRepositoryImpl(
            remoteDataSource: dataSource,
          );
          return BlocProvider(
            create: (_) => PrivacyBloc(repository: repository),
            child: const PrivacyScreen(),
          );
        },
      ),

      // Customers
      GoRoute(
        path: RouteNames.customers,
        builder: (_, __) => const CustomersListScreen(),
      ),
      GoRoute(
        path: RouteNames.customerDetail,
        builder: (_, state) {
          final customerId = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: customerId);
        },
      ),

      // Chat
      GoRoute(
        path: RouteNames.chat,
        builder: (context, __) {
          final dio = context.read<DioClient>().dio;
          final repository = ChatRepository(dio);
          return BlocProvider(
            create: (_) => ConversationsBloc(repository: repository)
              ..add(const ConversationsLoadRequested()),
            child: ConversationsScreen(repository: repository),
          );
        },
      ),

      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, __) {
          final dio = context.read<DioClient>().dio;
          return BlocProvider(
            create: (_) => NotificationsBloc(
              repository: NotificationRepository(dio),
            )..add(const NotificationsLoadRequested()),
            child: const NotificationsScreen(),
          );
        },
      ),

      // SOS
      GoRoute(
        path: RouteNames.sosHistory,
        builder: (context, __) {
          final dio = context.read<DioClient>().dio;
          return SosHistoryScreen(repository: SosRepository(dio));
        },
      ),

      // Badge
      GoRoute(
        path: RouteNames.badge,
        builder: (context, __) {
          final dio = context.read<DioClient>().dio;
          return BlocProvider(
            create: (_) => BadgeBloc(repository: BadgeRepository(dio))
              ..add(const BadgeLoadRequested()),
            child: const BadgeScreen(),
          );
        },
      ),
      // Gamification
      GoRoute(
        path: RouteNames.gamification,
        builder: (context, __) {
          final dio = context.read<DioClient>().dio;
          return BlocProvider(
            create: (_) =>
                GamificationBloc(repository: GamificationRepository(dio))
                  ..add(const GamificationLoadRequested()),
            child: const GamificationScreen(),
          );
        },
      ),

      // Partners
      GoRoute(
        path: RouteNames.partners,
        builder: (_, __) => const PartnersListScreen(),
      ),
      GoRoute(
        path: RouteNames.partnerDetail,
        builder: (_, state) {
          final partner = state.extra! as PartnerModel;
          return PartnerDetailScreen(partner: partner);
        },
      ),
    ],
  );
}
