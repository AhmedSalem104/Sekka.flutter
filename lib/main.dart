import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/routing/app_router.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_form_bloc.dart';
import 'features/home/presentation/bloc/daily_stats_bloc.dart';
import 'features/orders/data/datasources/order_remote_datasource.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/partners/data/repositories/partner_repository.dart';
import 'features/settlements/data/datasources/settlement_remote_datasource.dart';
import 'features/settlements/data/repositories/settlement_repository_impl.dart';
import 'features/settlements/presentation/bloc/settlement_bloc.dart';
import 'features/statistics/data/datasources/statistics_remote_datasource.dart';
import 'features/statistics/data/repositories/statistics_repository_impl.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/settings/data/datasources/settings_remote_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'shared/network/dio_client.dart';
import 'shared/storage/token_storage.dart';
import 'shared/storage/user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize storage
  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage();
  final userStorage = UserStorage(prefs);

  // Auth status notifier for GoRouter
  final authStatusNotifier = ValueNotifier<bool>(false);

  // Theme & locale notifiers for Settings
  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  final localeNotifier = ValueNotifier<Locale>(const Locale('ar'));

  // Late-init AuthBloc reference for the interceptor callback
  late final AuthBloc authBloc;

  // Initialize network
  final dioClient = DioClient(
    tokenStorage: tokenStorage,
    onSessionExpired: () {
      authBloc.add(const AuthSessionExpired());
    },
  );

  // Build repository
  final authRemoteDataSource = AuthRemoteDataSource(dioClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
    userStorage: userStorage,
  );

  // Create BLoC
  authBloc = AuthBloc(
    repository: authRepository,
    tokenStorage: tokenStorage,
    userStorage: userStorage,
    authStatusNotifier: authStatusNotifier,
  );

  // Statistics
  final statisticsDataSource = StatisticsRemoteDataSource(dioClient);
  final statisticsRepository =
      StatisticsRepositoryImpl(remoteDataSource: statisticsDataSource);

  // Settlements
  final settlementDataSource = SettlementRemoteDataSource(dioClient);
  final settlementRepository =
      SettlementRepositoryImpl(remoteDataSource: settlementDataSource);

  // Partners
  final partnerRepository = PartnerRepository(dioClient.dio);

  // Wallet
  final walletDataSource = WalletRemoteDataSource(dioClient);
  final walletRepository =
      WalletRepositoryImpl(remoteDataSource: walletDataSource);

  // Profile
  final profileDataSource = ProfileRemoteDataSource(dioClient);
  final profileRepository =
      ProfileRepositoryImpl(remoteDataSource: profileDataSource);

  // Orders
  final orderDataSource = OrderRemoteDataSource(dioClient);
  final orderRepository =
      OrderRepositoryImpl(remoteDataSource: orderDataSource);

  // Settings
  final settingsDataSource = SettingsRemoteDataSource(dioClient);
  final settingsRepository =
      SettingsRepositoryImpl(remoteDataSource: settingsDataSource);

  // Create router
  final router = createAppRouter(authStatusNotifier);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider.value(value: dioClient),
        RepositoryProvider.value(value: tokenStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(
            create: (_) => AuthFormBloc(repository: authRepository),
          ),
          BlocProvider(
            create: (_) => WalletBloc(repository: walletRepository),
          ),
          BlocProvider(
            create: (_) => DailyStatsBloc(repository: statisticsRepository)
              ..add(const DailyStatsLoadRequested()),
          ),
          BlocProvider(
            create: (_) => SettlementBloc(
              repository: settlementRepository,
              partnerRepository: partnerRepository,
            ),
          ),
          BlocProvider(
            create: (_) => ProfileBloc(repository: profileRepository),
          ),
          BlocProvider(
            create: (_) => OrdersBloc(repository: orderRepository),
          ),
          BlocProvider(
            create: (_) => SettingsBloc(
              repository: settingsRepository,
              themeModeNotifier: themeModeNotifier,
              localeNotifier: localeNotifier,
            ),
          ),
        ],
        child: SekkaApp(
          router: router,
          themeModeNotifier: themeModeNotifier,
          localeNotifier: localeNotifier,
        ),
      ),
    ),
  );
}
