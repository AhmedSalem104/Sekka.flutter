import '../entities/auth_tokens.dart';
import '../entities/session_entity.dart';
import '../entities/vehicle_type_entity.dart';

abstract class AuthRepository {
  Future<List<VehicleTypeEntity>> getVehicleTypes();

  Future<void> sendVerification(String phoneNumber);

  Future<AuthTokens> register({
    required String phoneNumber,
    required String otpCode,
    required String password,
    required String confirmPassword,
    required String name,
    required int vehicleType,
    String? email,
  });

  Future<AuthTokens> login({
    required String phoneNumber,
    required String password,
  });

  Future<void> forgotPassword(String phoneNumber);

  Future<void> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<AuthTokens> refreshToken({
    required String token,
    required String refreshToken,
  });

  Future<void> logout();

  Future<void> registerDevice({
    required String fcmToken,
    required int platform,
  });

  Future<List<SessionEntity>> getSessions();

  Future<void> terminateSession(String sessionId);

  Future<void> logoutAll();

  Future<void> deleteAccount({String? reason});

  Future<void> confirmDeletion(String confirmationCode);
}
