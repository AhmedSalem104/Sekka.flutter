import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.phoneNumber,
    required this.password,
  });

  final String phoneNumber;
  final String password;

  @override
  List<Object?> get props => [phoneNumber, password];
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.phoneNumber,
    required this.otpCode,
    required this.password,
    required this.confirmPassword,
    required this.name,
    required this.vehicleType,
    this.email,
  });

  final String phoneNumber;
  final String otpCode;
  final String password;
  final String confirmPassword;
  final String name;
  final int vehicleType;
  final String? email;

  @override
  List<Object?> get props => [
        phoneNumber,
        otpCode,
        password,
        confirmPassword,
        name,
        vehicleType,
        email,
      ];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
