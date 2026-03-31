import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.driver);

  final DriverEntity driver;

  @override
  List<Object?> get props => [driver];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Emitted after DELETE /auth/account succeeds — OTP was sent to phone.
final class AuthDeletionOtpSent extends AuthState {
  const AuthDeletionOtpSent();
}

/// Emitted when an API error occurs during the deletion flow, while the
/// session is still valid. Carries the error message + the current driver
/// so the profile screen can restore context.
final class AuthDeletionError extends AuthState {
  const AuthDeletionError({required this.message, required this.driver});

  final String message;
  final DriverEntity driver;

  @override
  List<Object?> get props => [message, driver];
}
