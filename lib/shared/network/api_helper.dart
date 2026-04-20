import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/app_strings.dart';
import 'api_result.dart';

/// Helper to execute API calls with unified error handling.
///
/// Automatically unwraps the Sekka API response format:
/// `{ isSuccess: bool, data: T, message: string, errors: any }`
abstract final class ApiHelper {
  static Future<ApiResult<T>> execute<T>(
    Future<Response<dynamic>> Function() call, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await call();
      final body = response.data;

      // Unwrap Sekka API response: { isSuccess, data, message, errors }
      if (body is Map<String, dynamic> && body.containsKey('isSuccess')) {
        final isSuccess = body['isSuccess'] as bool? ?? false;
        final innerData = body['data'];
        final message = body['message'] as String?;

        if (!isSuccess) {
          return ApiFailure<T>(
            ApiError(
              message: message ?? AppStrings.somethingWentWrong,
              statusCode: response.statusCode,
            ),
          );
        }

        final parsed = parser != null ? parser(innerData) : innerData as T;
        return ApiSuccess<T>(parsed);
      }

      // Fallback: raw response
      final data = parser != null ? parser(body) : body as T;
      return ApiSuccess<T>(data);
    } on DioException catch (e) {
      return ApiFailure<T>(_handleDioError(e));
    } on SocketException {
      return ApiFailure<T>(
        ApiError(
          message: AppStrings.noInternetConnection,
          statusCode: 0,
        ),
      );
    } catch (e) {
      return ApiFailure<T>(
        ApiError(
          message: e.toString(),
          statusCode: -1,
        ),
      );
    }
  }

  static ApiError _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: AppStrings.requestTimedOut,
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return ApiError(
          message: AppStrings.noInternetConnection,
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        String message = AppStrings.somethingWentWrong;

        if (data is Map<String, dynamic>) {
          message = (data['message'] as String?) ??
              (data['title'] as String?) ??
              message;
        }

        return ApiError(
          message: message,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiError(
          message: AppStrings.requestCancelled,
          statusCode: -1,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiError(
          message: e.message ?? AppStrings.unexpectedError,
          statusCode: -1,
        );
    }
  }
}
