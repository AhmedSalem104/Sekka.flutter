import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/app_strings.dart';
import 'error_mapper.dart';

class ApiException implements Exception {
  ApiException({
    required String message,
    this.statusCode,
  }) : message = ErrorMapper.toUserMessage(message);

  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: AppStrings.timeoutError);

      case DioExceptionType.connectionError:
        return ApiException(message: AppStrings.networkError);

      case DioExceptionType.badResponse:
        return _fromResponse(error.response);

      case DioExceptionType.cancel:
        return ApiException(message: AppStrings.unknownError);

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return ApiException(message: AppStrings.networkError);
        }
        return ApiException(message: AppStrings.unknownError);
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    if (response?.data case final Map<String, dynamic> data) {
      return ApiException(
        message: data['message'] as String? ?? AppStrings.unknownError,
        statusCode: response?.statusCode,
      );
    }

    final statusCode = response?.statusCode;
    return ApiException(
      message: switch (statusCode) {
        401 => AppStrings.sessionExpired,
        409 => 'الرقم ده مسجّل قبل كدا، جرّب تسجّل دخول',
        429 => 'جرّبت كتير، استنى شوية وحاول تاني',
        503 => 'الخدمة مش متاحة دلوقتي، جرّب بعد شوية',
        final code? when code >= 500 => AppStrings.serverError,
        _ => AppStrings.unknownError,
      },
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
