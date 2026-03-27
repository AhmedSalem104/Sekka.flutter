import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_event.dart';
import 'auth_form_state.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthFormState()) {
    on<AuthFormTabChanged>(_onTabChanged);
    on<AuthFormSendOtp>(_onSendOtp);
    on<AuthFormResendOtp>(_onResendOtp);
    on<AuthFormTimerTick>(_onTimerTick);
    on<AuthFormTimerStarted>(_onTimerStarted);
    on<AuthFormForgotPassword>(_onForgotPassword);
    on<AuthFormResetPassword>(_onResetPassword);
    on<AuthFormLoadVehicleTypes>(_onLoadVehicleTypes);
    on<AuthFormErrorCleared>(_onErrorCleared);
  }

  final AuthRepository _repository;
  Timer? _otpTimer;

  void _onTabChanged(
    AuthFormTabChanged event,
    Emitter<AuthFormState> emit,
  ) {
    emit(state.copyWith(
      activeTab: event.tabIndex,
      status: AuthFormStatus.initial,
      errorMessage: () => null,
    ));
  }

  Future<void> _onSendOtp(
    AuthFormSendOtp event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthFormStatus.loading,
      errorMessage: () => null,
    ));
    try {
      await _repository.sendVerification(event.phoneNumber);
      emit(state.copyWith(status: AuthFormStatus.success));
      _startOtpTimer(emit);
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: () => e.message,
      ));
    }
  }

  Future<void> _onResendOtp(
    AuthFormResendOtp event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthFormStatus.loading,
      errorMessage: () => null,
    ));
    try {
      await _repository.sendVerification(event.phoneNumber);
      emit(state.copyWith(status: AuthFormStatus.success));
      _startOtpTimer(emit);
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: () => e.message,
      ));
    }
  }

  void _onTimerTick(AuthFormTimerTick event, Emitter<AuthFormState> emit) {
    final newSeconds = state.otpCountdownSeconds - 1;
    if (newSeconds <= 0) {
      _otpTimer?.cancel();
      emit(state.copyWith(
        otpCountdownSeconds: 0,
        canResendOtp: true,
      ));
    } else {
      emit(state.copyWith(otpCountdownSeconds: newSeconds));
    }
  }

  void _onTimerStarted(
    AuthFormTimerStarted event,
    Emitter<AuthFormState> emit,
  ) {
    _startOtpTimer(emit);
  }

  void _startOtpTimer(Emitter<AuthFormState> emit) {
    _otpTimer?.cancel();
    emit(state.copyWith(
      otpCountdownSeconds: 60,
      canResendOtp: false,
    ));
    _otpTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const AuthFormTimerTick()),
    );
  }

  Future<void> _onForgotPassword(
    AuthFormForgotPassword event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthFormStatus.loading,
      errorMessage: () => null,
    ));
    try {
      await _repository.forgotPassword(event.phoneNumber);
      emit(state.copyWith(status: AuthFormStatus.success));
      _startOtpTimer(emit);
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: () => e.message,
      ));
    }
  }

  Future<void> _onResetPassword(
    AuthFormResetPassword event,
    Emitter<AuthFormState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthFormStatus.loading,
      errorMessage: () => null,
    ));
    try {
      await _repository.resetPassword(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(state.copyWith(status: AuthFormStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: () => e.message,
      ));
    }
  }

  Future<void> _onLoadVehicleTypes(
    AuthFormLoadVehicleTypes event,
    Emitter<AuthFormState> emit,
  ) async {
    try {
      final types = await _repository.getVehicleTypes();
      emit(state.copyWith(vehicleTypes: types));
    } on ApiException {
      // Silently fail — vehicle types are not critical
    }
  }

  void _onErrorCleared(
    AuthFormErrorCleared event,
    Emitter<AuthFormState> emit,
  ) {
    emit(state.copyWith(
      status: AuthFormStatus.initial,
      errorMessage: () => null,
    ));
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
