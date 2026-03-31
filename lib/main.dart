import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/routing/app_router.dart';
import 'shared/offline/offline_queue_service.dart';
import 'shared/offline/queue_operation.dart';
import 'dart:convert';

import 'shared/offline/sync_queue_service.dart';
import 'shared/services/connectivity_service.dart';
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
import 'features/search/data/repositories/search_repository.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
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
import 'features/breaks/data/datasources/break_remote_datasource.dart';
import 'features/breaks/data/repositories/break_repository_impl.dart';
import 'features/breaks/presentation/bloc/break_bloc.dart';
import 'features/sync/data/datasources/sync_remote_datasource.dart';
import 'features/sync/data/repositories/sync_repository_impl.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';
import 'features/sync/presentation/bloc/sync_event.dart';
import 'features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'shared/network/dio_client.dart';
import 'shared/storage/token_storage.dart';
import 'shared/storage/user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first infrastructure
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  await Hive.initFlutter();
  await ConnectivityService.instance.initialize();

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

  // Search
  final searchRepository = SearchRepository(dioClient.dio);

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

  // Sync
  final syncDataSource = SyncRemoteDataSource(dioClient);
  final syncRepository =
      SyncRepositoryImpl(remoteDataSource: syncDataSource);

  // Sync queue — handles offline order creation via /sync/push
  await SyncQueueService.instance.initialize(
    executor: (changes) async {
      final result = await syncDataSource.push(data: {
        'changes': changes
            .map((c) => {
                  'entityType': c.entityType,
                  'operationType': c.operationType,
                  'tempId': c.tempId,
                  'payload': jsonEncode(c.payload),
                })
            .toList(),
        'deviceTimestamp': DateTime.now().toUtc().toIso8601String(),
      });
      return result.syncedItems
          .map((item) => SyncedItem(
                tempId: item.tempId,
                realId: item.realId,
                entityType: item.entityType,
              ))
          .toList();
    },
  );

  // Breaks
  final breakDataSource = BreakRemoteDataSource(dioClient);
  final breakRepository =
      BreakRepositoryImpl(remoteDataSource: breakDataSource);

  // Offline write queue — flushes ALL pending actions when back online
  await OfflineQueueService.instance.initialize(
    executor: (op) async {
      switch (op.type) {
        // Order actions
        case QueueOperationType.deliver:
          await orderRepository.deliverOrder(op.orderId, op.payload);
        case QueueOperationType.fail:
          await orderRepository.failOrder(op.orderId, op.payload);
        case QueueOperationType.cancel:
          await orderRepository.cancelOrder(op.orderId, op.payload);
        case QueueOperationType.update:
          await orderRepository.updateOrder(op.orderId, op.payload);
        case QueueOperationType.statusChange:
          await orderRepository.updateOrderStatus(op.orderId, op.payload);
        case QueueOperationType.transfer:
          await orderRepository.transferOrder(op.orderId, op.payload);
        case QueueOperationType.partial:
          await orderRepository.partialDelivery(op.orderId, op.payload);
        case QueueOperationType.swapAddress:
          await orderRepository.swapAddress(op.orderId, op.payload);
        case QueueOperationType.waitingStart:
          await orderRepository.startWaitingTimer(op.orderId);
        case QueueOperationType.waitingStop:
          await orderRepository.stopWaitingTimer(op.orderId);
        // Settlement actions
        case QueueOperationType.settlementCreate:
          await settlementRepository.createSettlement(
            partnerId: op.payload['partnerId'] as String,
            amount: (op.payload['amount'] as num).toDouble(),
            settlementType: op.payload['settlementType'] as int,
            orderCount: op.payload['orderCount'] as int,
            notes: op.payload['notes'] as String?,
          );
        // Profile actions
        case QueueOperationType.profileUpdate:
          await profileRepository.updateProfile(op.payload);
        // Break actions
        case QueueOperationType.breakStart:
          await breakRepository.startBreak(
            energyBefore: op.payload['energyBefore'] as int,
            locationDescription: op.payload['locationDescription'] as String,
          );
        case QueueOperationType.breakEnd:
          await breakRepository.endBreak(
            energyAfter: op.payload['energyAfter'] as int,
          );
      }
    },
  );

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
            create: (_) {
              final bloc = DailyStatsBloc(repository: statisticsRepository);
              if (bloc.state is DailyStatsLoaded) {
                bloc.add(const DailyStatsRefreshRequested());
              } else {
                bloc.add(const DailyStatsLoadRequested());
              }
              return bloc;
            },
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
            create: (_) => OrdersBloc(
              repository: orderRepository,
              searchRepository: searchRepository,
            ),
          ),
          BlocProvider(
            create: (_) => SearchBloc(repository: searchRepository),
          ),
          BlocProvider(
            create: (_) => SettingsBloc(
              repository: settingsRepository,
              themeModeNotifier: themeModeNotifier,
              localeNotifier: localeNotifier,
            ),
          ),
          BlocProvider(
            create: (_) => SyncBloc(repository: syncRepository)
              ..add(const SyncStatusRequested()),
          ),
          BlocProvider(
            create: (_) => BreakBloc(repository: breakRepository)
              ..add(const BreakCheckRequested()),
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
