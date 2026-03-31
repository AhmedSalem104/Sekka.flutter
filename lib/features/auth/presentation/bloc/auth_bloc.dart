import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_exception.dart';
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
    required this.authStatusNotifier,
  })  : _repository = repository,
        _tokenStorage = tokenStorage,
        _userStorage = userStorage,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
    on<AuthConfirmDeletionRequested>(_onConfirmDeletion);
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final UserStorage _userStorage;

  /// Notifies GoRouter when auth state changes.
  final ValueNotifier<bool> authStatusNotifier;

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
    await _tokenStorage.clearTokens();
    await _userStorage.clearDriver();
    authStatusNotifier.value = false;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _tokenStorage.clearTokens();
    await _userStorage.clearDriver();
    authStatusNotifier.value = false;
    emit(const AuthUnauthenticated(message: 'انتهت الجلسة، سجّل دخولك تاني'));
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
      await _tokenStorage.clearTokens();
      await _userStorage.clearDriver();
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
