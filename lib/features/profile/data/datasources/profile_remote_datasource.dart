import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../../shared/network/paginated_response.dart';
import '../models/emergency_contact_model.dart';
import '../models/expense_model.dart';
import '../models/leaderboard_model.dart';
import '../models/profile_completion_model.dart';
import '../models/profile_model.dart';
import '../models/profile_stats_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  // ── GET endpoints ──────────────────────────────────────────────────

  Future<ProfileModel> getProfile() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.profile);
      final apiResponse = ApiResponse<ProfileModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ProfileModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProfileCompletionModel> getCompletion() async {
    try {
      final response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.profileCompletion);
      final apiResponse = ApiResponse<ProfileCompletionModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ProfileCompletionModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProfileStatsModel> getStats() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.profileStats);
      final apiResponse = ApiResponse<ProfileStatsModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ProfileStatsModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<LeaderboardModel> getLeaderboard() async {
    try {
      final response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.profileLeaderboard);
      final apiResponse = ApiResponse<LeaderboardModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            LeaderboardModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    try {
      final response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.profileEmergencyContacts);
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      final data = json['data'] as List<dynamic>? ?? [];
      return data
          .map((e) =>
              EmergencyContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PaginatedResponse<ExpenseModel>> getExpenses({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.profileExpenses,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }

      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return PaginatedResponse.fromJson(
          data,
          fromJsonT: ExpenseModel.fromJson,
        );
      }

      final items = (data as List)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedResponse<ExpenseModel>(
        items: items,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalCount: items.length,
        totalPages: 1,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ── PUT / POST / DELETE endpoints ──────────────────────────────────

  Future<ProfileModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.profile,
        data: updates,
      );
      final apiResponse = ApiResponse<ProfileModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            ProfileModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.profileImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as String? ?? '';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final response = await _dio
          .delete<Map<String, dynamic>>(ApiConstants.profileImage);
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<String> uploadLicenseImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.profileLicenseImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
      return json['data'] as String? ?? '';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<EmergencyContactModel> addEmergencyContact(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.profileEmergencyContacts,
        data: data,
      );
      final apiResponse = ApiResponse<EmergencyContactModel>.fromJson(
        response.data!,
        fromJsonT: (d) =>
            EmergencyContactModel.fromJson(d as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteEmergencyContact(String id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        ApiConstants.profileEmergencyContact(id),
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.profileExpenses,
        data: data,
      );
      final json = response.data!;
      if (json['isSuccess'] != true) {
        throw ApiException(message: json['message'] as String? ?? '');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
