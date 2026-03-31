import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/session_model.dart';
import '../models/vehicle_type_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  // ── Helper to reduce repetition ──

  Future<Map<String, dynamic>> _post(
    String path, {
    Object? data,
    Options? options,
  }) async {
    final response =
        await _dio.post<Map<String, dynamic>>(path, data: data, options: options);
    return response.data!;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    return response.data!;
  }

  Future<Map<String, dynamic>> _delete(
    String path, {
    Object? data,
  }) async {
    final response =
        await _dio.delete<Map<String, dynamic>>(path, data: data);
    return response.data!;
  }

  void _ensureSuccess(ApiResponse<dynamic> apiResponse) {
    if (!apiResponse.isSuccess) {
      throw ApiException(message: apiResponse.message ?? '');
    }
  }

  // ── Endpoints ──

  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    try {
      final json = await _get(ApiConstants.vehicleTypes);
      final apiResponse = ApiResponse<List<VehicleTypeModel>>.fromJson(
        json,
        fromJsonT: (data) => (data as List)
            .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _ensureSuccess(apiResponse);
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> sendVerification(String phoneNumber) async {
    try {
      final json =
          await _post(ApiConstants.sendVerification, data: {'phoneNumber': phoneNumber});
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResponseModel> register({
    required String phoneNumber,
    required String otpCode,
    required String password,
    required String confirmPassword,
    required String name,
    required int vehicleType,
    String? email,
    String? referralCode,
  }) async {
    try {
      final json = await _post(
        ApiConstants.register,
        data: {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
          'password': password,
          'confirmPassword': confirmPassword,
          'name': name,
          'vehicleType': vehicleType,
          if (email != null && email.isNotEmpty) 'email': email,
          if (referralCode != null && referralCode.isNotEmpty)
            'referralCode': referralCode,
        },
      );
      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        json,
        fromJsonT: (data) =>
            AuthResponseModel.fromJson(data as Map<String, dynamic>),
      );
      _ensureSuccess(apiResponse);
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final json = await _post(
        ApiConstants.login,
        data: {'phoneNumber': phoneNumber, 'password': password},
      );
      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        json,
        fromJsonT: (data) =>
            AuthResponseModel.fromJson(data as Map<String, dynamic>),
      );
      _ensureSuccess(apiResponse);
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> forgotPassword(String phoneNumber) async {
    try {
      final json =
          await _post(ApiConstants.forgotPassword, data: {'phoneNumber': phoneNumber});
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final json = await _post(
        ApiConstants.resetPassword,
        data: {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final json = await _post(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResponseModel> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    try {
      final json = await _post(
        ApiConstants.refreshToken,
        data: {'token': token, 'refreshToken': refreshToken},
      );
      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        json,
        fromJsonT: (data) =>
            AuthResponseModel.fromJson(data as Map<String, dynamic>),
      );
      _ensureSuccess(apiResponse);
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiConstants.logout,
        options: Options(headers: {'Content-Length': '0'}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> registerDevice({
    required String fcmToken,
    required int platform,
  }) async {
    try {
      final json = await _post(
        ApiConstants.registerDevice,
        data: {'token': fcmToken, 'platform': platform},
      );
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<SessionModel>> getSessions() async {
    try {
      final json = await _get(ApiConstants.sessions);
      final apiResponse = ApiResponse<List<SessionModel>>.fromJson(
        json,
        fromJsonT: (data) => (data as List)
            .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _ensureSuccess(apiResponse);
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> terminateSession(String sessionId) async {
    try {
      final json = await _delete('${ApiConstants.sessions}/$sessionId');
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logoutAll() async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiConstants.logoutAll,
        options: Options(headers: {'Content-Length': '0'}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteAccount({String? reason}) async {
    try {
      final json = await _delete(
        ApiConstants.deleteAccount,
        data: {'reason': reason ?? ''},
      );
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> confirmDeletion(String confirmationCode) async {
    try {
      final json = await _post(
        ApiConstants.confirmDeletion,
        data: {'confirmationCode': confirmationCode},
      );
      _ensureSuccess(ApiResponse<void>.fromJson(json));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
