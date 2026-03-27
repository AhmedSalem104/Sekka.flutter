import '../../../../shared/storage/token_storage.dart';
import '../../../../shared/storage/user_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/vehicle_type_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
    required UserStorage userStorage,
  })  : _remote = remoteDataSource,
        _tokenStorage = tokenStorage,
        _userStorage = userStorage;

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final UserStorage _userStorage;

  /// Persists tokens and driver data after successful auth.
  Future<AuthTokens> _persistAuth(AuthResponseModel response) async {
    await _tokenStorage.saveTokens(
      token: response.token,
      refreshToken: response.refreshToken,
      expiresAt: response.expiresAt,
    );
    await _userStorage.saveDriver(response.driverModel.toJson());
    return response;
  }

  /// Clears all stored auth data.
  Future<void> _clearAuth() async {
    await _tokenStorage.clearTokens();
    await _userStorage.clearDriver();
  }

  @override
  Future<List<VehicleTypeEntity>> getVehicleTypes() =>
      _remote.getVehicleTypes();

  @override
  Future<void> sendVerification(String phoneNumber) =>
      _remote.sendVerification(phoneNumber);

  @override
  Future<AuthTokens> register({
    required String phoneNumber,
    required String otpCode,
    required String password,
    required String confirmPassword,
    required String name,
    required int vehicleType,
    String? email,
  }) async {
    final response = await _remote.register(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      vehicleType: vehicleType,
      email: email,
    );
    return _persistAuth(response);
  }

  @override
  Future<AuthTokens> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _remote.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    return _persistAuth(response);
  }

  @override
  Future<void> forgotPassword(String phoneNumber) =>
      _remote.forgotPassword(phoneNumber);

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _remote.resetPassword(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

  @override
  Future<AuthTokens> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    final response = await _remote.refreshToken(
      token: token,
      refreshToken: refreshToken,
    );
    return _persistAuth(response);
  }

  @override
  Future<void> logout() async {
    await _remote.logout();
    await _clearAuth();
  }

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required int platform,
  }) =>
      _remote.registerDevice(fcmToken: fcmToken, platform: platform);

  @override
  Future<List<SessionEntity>> getSessions() => _remote.getSessions();

  @override
  Future<void> terminateSession(String sessionId) =>
      _remote.terminateSession(sessionId);

  @override
  Future<void> logoutAll() async {
    await _remote.logoutAll();
    await _clearAuth();
  }

  @override
  Future<void> deleteAccount({String? reason}) async {
    await _remote.deleteAccount(reason: reason);
  }

  @override
  Future<void> confirmDeletion(String confirmationCode) async {
    await _remote.confirmDeletion(confirmationCode);
    await _clearAuth();
  }
}
