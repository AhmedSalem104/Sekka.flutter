import 'dart:io';

import 'package:dio/dio.dart';
import 'api_result.dart';

/// Helper to execute API calls with unified error handling.
///
/// Usage:
/// ```dart
/// final result = await ApiHelper.execute(
///   () => ApiClient.instance.dio.get('/api/orders'),
/// );
/// ```
abstract final class ApiHelper {
  /// Executes an API call and wraps the result in [ApiResult].
  static Future<ApiResult<T>> execute<T>(
    Future<Response<dynamic>> Function() call, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await call();
      final data = parser != null
          ? parser(response.data)
          : response.data as T;
      return ApiSuccess<T>(data);
    } on DioException catch (e) {
      return ApiFailure<T>(_handleDioError(e));
    } on SocketException {
      return ApiFailure<T>(
        const ApiError(
          message: 'مفيش إنترنت — تأكد من الاتصال',
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
        return const ApiError(
          message: 'انتهت المهلة — جرّب تاني',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return const ApiError(
          message: 'مفيش إنترنت — تأكد من الاتصال',
          statusCode: 0,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        String message = 'حصلت مشكلة';
        Map<String, List<String>>? errors;

        if (data is Map<String, dynamic>) {
          message = (data['message'] as String?) ??
              (data['title'] as String?) ??
              message;

          if (data['errors'] is Map) {
            errors = (data['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>).cast<String>(),
              ),
            );
          }
        }

        return ApiError(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );

      case DioExceptionType.cancel:
        return const ApiError(
          message: 'تم إلغاء الطلب',
          statusCode: -1,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiError(
          message: e.message ?? 'حصلت مشكلة غير متوقعة',
          statusCode: -1,
        );
    }
  }
}
