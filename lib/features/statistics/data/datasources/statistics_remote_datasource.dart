import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../models/daily_stats_model.dart';
import '../models/monthly_stats_model.dart';
import '../models/weekly_stats_model.dart';

class StatisticsRemoteDataSource {
  StatisticsRemoteDataSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<DailyStatsModel> getDailyStats({String? date}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.statisticsDaily,
        queryParameters: {if (date != null) 'date': date},
      );
      final apiResponse = ApiResponse<DailyStatsModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            DailyStatsModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WeeklyStatsModel> getWeeklyStats({String? weekStart}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.statisticsWeekly,
        queryParameters: {if (weekStart != null) 'weekStart': weekStart},
      );
      final apiResponse = ApiResponse<WeeklyStatsModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            WeeklyStatsModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<MonthlyStatsModel> getMonthlyStats({int? month, int? year}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.statisticsMonthly,
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
      );
      final apiResponse = ApiResponse<MonthlyStatsModel>.fromJson(
        response.data!,
        fromJsonT: (data) =>
            MonthlyStatsModel.fromJson(data as Map<String, dynamic>),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ApiException(message: apiResponse.message ?? '');
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
