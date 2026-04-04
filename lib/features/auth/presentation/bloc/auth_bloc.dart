import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/offline/offline_queue_service.dart';
import '../../../../shared/offline/sync_queue_service.dart';
import '../../../../shared/storage/token_storage.dart';
import '../../../../shared/storage/user_storage.dart';
import '../../data/models/driver_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
    required UserStorage userStorage,
    required Dio dio,
    required this.authStatusNotifier,
  })  : _repository = repository,
        _tokenStorage = tokenStorage,
        _userStorage = userStorage,
        _dio = dio,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
    on<AuthConfirmDeletionRequested>(_onConfirmDeletion);
    on<AuthDemoRequested>(_onDemo);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final UserStorage _userStorage;
  final Dio _dio;

  /// Notifies GoRouter when auth state changes.
  final ValueNotifier<bool> authStatusNotifier;

  /// Clears all local data: tokens, user, cached bloc states, offline queues.
  Future<void> _clearAllLocalData() async {
    await _tokenStorage.clearTokens();
    await _userStorage.clearDriver();
    await HydratedBloc.storage.clear();
    try {
      await OfflineQueueService.instance.clear();
      await SyncQueueService.instance.clear();
    } catch (_) {
      // Queue services may not be initialized
    }
  }

  Future<void> _onCheckAuth(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await _tokenStorage.hasValidToken();
    if (hasToken) {
      final driverJson = _userStorage.getDriver();
      if (driverJson != null) {
        final driver = DriverModel.fromJson(driverJson);
        authStatusNotifier.value = true;
        emit(AuthAuthenticated(driver));
        return;
      }
    }
    authStatusNotifier.value = false;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final authTokens = await _repository.login(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );
      authStatusNotifier.value = true;
      emit(AuthAuthenticated(authTokens.driver));
    } on ApiException catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final authTokens = await _repository.register(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
        password: event.password,
        confirmPassword: event.confirmPassword,
        name: event.name,
        vehicleType: event.vehicleType,
        email: event.email,
        referralCode: event.referralCode,
      );
      authStatusNotifier.value = true;
      emit(AuthAuthenticated(authTokens.driver));
    } on ApiException catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.logout();
    } catch (_) {
      // Even if server logout fails, clear local state
    }
    await _clearAllLocalData();
    authStatusNotifier.value = false;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _clearAllLocalData();
    authStatusNotifier.value = false;
    emit(const AuthUnauthenticated(message: 'الجلسة خلصت، سجّل دخولك تاني'));
  }

  Future<void> _onDemo(
    AuthDemoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.demoStart,
      );
      final body = response.data!;
      if (body['isSuccess'] != true || body['data'] == null) {
        emit(AuthUnauthenticated(
          message: body['message'] as String? ?? 'فشل تشغيل الوضع التجريبي',
        ));
        return;
      }

      final data = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final driverId = data['demoDriverId'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);

      await _tokenStorage.saveTokens(
        token: token,
        refreshToken: '',
        expiresAt: expiresAt,
      );

      final demoDriver = DriverModel(
        id: driverId,
        name: 'سائق تجريبي',
        phone: '+201000000000',
        vehicleType: 0,
        joinedAt: DateTime.now(),
      );
      await _userStorage.saveDriver(demoDriver.toJson());

      authStatusNotifier.value = true;
      emit(AuthAuthenticated(demoDriver));
    } on DioException catch (e) {
      emit(AuthUnauthenticated(
        message: e.response?.data?['message'] as String? ??
            'مفيش إنترنت — جرّب تاني',
      ));
    }
  }

  Future<void> _onDeleteAccount(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    emit(const AuthLoading());
    try {
      await _repository.deleteAccount(reason: event.reason);
      emit(const AuthDeletionOtpSent());
    } on ApiException catch (e) {
      // Restore the previous authenticated state with the error
      if (currentState is AuthAuthenticated) {
        emit(AuthDeletionError(message: e.message, driver: currentState.driver));
      } else {
        emit(AuthUnauthenticated(message: e.message));
      }
    }
  }

  Future<void> _onConfirmDeletion(
    AuthConfirmDeletionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final driverJson = _userStorage.getDriver();
    final savedDriver =
        driverJson != null ? DriverModel.fromJson(driverJson) : null;
    emit(const AuthLoading());
    try {
      await _repository.confirmDeletion(event.otpCode);
      await _clearAllLocalData();
      authStatusNotifier.value = false;
      emit(const AuthUnauthenticated());
    } on ApiException catch (e) {
      if (savedDriver != null) {
        emit(AuthDeletionError(message: e.message, driver: savedDriver));
      } else {
        emit(const AuthDeletionOtpSent());
      }
    }
  }
}
