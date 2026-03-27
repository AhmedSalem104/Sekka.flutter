import 'package:equatable/equatable.dart';

sealed class AuthFormEvent extends Equatable {
  const AuthFormEvent();

  @override
  List<Object?> get props => [];
}

// Tab
final class AuthFormTabChanged extends AuthFormEvent {
  const AuthFormTabChanged(this.tabIndex);
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

// OTP
final class AuthFormSendOtp extends AuthFormEvent {
  const AuthFormSendOtp(this.phoneNumber);
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthFormResendOtp extends AuthFormEvent {
  const AuthFormResendOtp(this.phoneNumber);
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthFormTimerTick extends AuthFormEvent {
  const AuthFormTimerTick();
}

final class AuthFormTimerStarted extends AuthFormEvent {
  const AuthFormTimerStarted();
}

// Forgot Password
final class AuthFormForgotPassword extends AuthFormEvent {
  const AuthFormForgotPassword(this.phoneNumber);
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthFormResetPassword extends AuthFormEvent {
  const AuthFormResetPassword({
    required this.phoneNumber,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String phoneNumber;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [phoneNumber, otpCode, newPassword, confirmPassword];
}

// Vehicle Types
final class AuthFormLoadVehicleTypes extends AuthFormEvent {
  const AuthFormLoadVehicleTypes();
}

// Error clear
final class AuthFormErrorCleared extends AuthFormEvent {
  const AuthFormErrorCleared();
}
