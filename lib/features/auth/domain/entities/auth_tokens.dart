import 'package:equatable/equatable.dart';

import 'driver_entity.dart';

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    required this.isNewUser,
    required this.driver,
  });

  final String token;
  final String refreshToken;
  final DateTime expiresAt;
  final bool isNewUser;
  final DriverEntity driver;

  @override
  List<Object?> get props => [token, refreshToken, expiresAt, isNewUser, driver];
}
