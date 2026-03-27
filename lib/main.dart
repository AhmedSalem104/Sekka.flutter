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

  // Create router
  final router = createAppRouter(authStatusNotifier);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: dioClient),
        RepositoryProvider.value(value: tokenStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(
            create: (_) => AuthFormBloc(repository: authRepository),
          ),
        ],
        child: SekkaApp(router: router),
      ),
    ),
  );
}
