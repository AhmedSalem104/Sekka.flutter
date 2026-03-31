import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/break_model.dart';
import '../models/break_suggestion_model.dart';

class BreakRemoteDataSource {
  BreakRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<BreakSuggestionModel> getSuggestion() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.breakSuggestion,
      );
      final apiResponse = ApiResponse<BreakSuggestionModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            BreakSuggestionModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BreakModel?> getActiveBreak() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.breakActive,
      );
      final json = response.data;
      if (json == null) return null;
      // If data field is null, there is no active break
      if (json['data'] == null) return null;
      return BreakModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  Future<BreakModel> startBreak({
    required int energyBefore,
    required String locationDescription,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.breakStart,
        data: {
          'energyBefore': energyBefore,
          'locationDescription': locationDescription,
        },
      );
      final apiResponse = ApiResponse<BreakModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            BreakModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<BreakModel> endBreak({required int energyAfter}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.breakEnd,
        data: {'energyAfter': energyAfter},
      );
      final apiResponse = ApiResponse<BreakModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            BreakModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<BreakModel>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.breakHistory,
        queryParameters: {'Page': page, 'PageSize': pageSize},
      );
      final apiResponse = ApiResponse<List<BreakModel>>.fromJson(
        response.data!,
        fromJsonT: (data) {
          if (data is List) {
            return data
                .map((e) => BreakModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          // Paginated response
          if (data is Map<String, dynamic>) {
            final items = data['items'] as List? ?? [];
            return items
                .map((e) => BreakModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <BreakModel>[];
        },
      );
      if (!apiResponse.isSuccess) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
