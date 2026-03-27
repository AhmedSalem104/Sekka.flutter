import '../../domain/entities/auth_tokens.dart';
import 'driver_model.dart';

class AuthResponseModel extends AuthTokens {
  const AuthResponseModel({
    required super.token,
    required super.refreshToken,
    required super.expiresAt,
    required super.isNewUser,
    required DriverModel super.driver,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isNewUser: json['isNewUser'] as bool? ?? false,
      driver: DriverModel.fromJson(json['driver'] as Map<String, dynamic>),
    );
  }

  DriverModel get driverModel => driver as DriverModel;
}
