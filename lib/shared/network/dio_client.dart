import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../storage/token_storage.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart' hide VoidCallback;

class DioClient {
  DioClient({
    required TokenStorage tokenStorage,
    required void Function() onSessionExpired,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => dev.log(obj.toString(), name: 'DioClient'),
        ),
      );
    }
  }

  final Dio dio;
}
