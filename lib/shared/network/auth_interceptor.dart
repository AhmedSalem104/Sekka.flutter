import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_constants.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required VoidCallback onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired;

  final TokenStorage _tokenStorage;
  final VoidCallback _onSessionExpired;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!ApiConstants.isPublic(options.uri.toString())) {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't try to refresh if we're already on a public endpoint
    if (ApiConstants.isPublic(err.requestOptions.uri.toString())) {
      handler.next(err);
      return;
    }

    final oldToken = await _tokenStorage.getToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    // Demo mode — token starts with "demo_", skip refresh & session expiry
    if (oldToken != null && oldToken.startsWith('demo_')) {
      handler.next(err);
      return;
    }

    if (oldToken == null || refreshToken == null) {
      _onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      // Use a separate Dio to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'token': oldToken, 'refreshToken': refreshToken},
      );

      final data = response.data!;
      if (data['isSuccess'] == true && data['data'] != null) {
        final authData = data['data'] as Map<String, dynamic>;
        await _tokenStorage.saveTokens(
          token: authData['token'] as String,
          refreshToken: authData['refreshToken'] as String,
          expiresAt: DateTime.parse(authData['expiresAt'] as String),
        );

        // Retry the original request with the new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] =
            'Bearer ${authData['token']}';

        final retryDio = Dio();
        final retryResponse = await retryDio.fetch<dynamic>(retryOptions);
        handler.resolve(retryResponse);
        return;
      }
    } catch (_) {
      // Refresh failed
    }

    await _tokenStorage.clearTokens();
    _onSessionExpired();
    handler.next(err);
  }
}

typedef VoidCallback = void Function();
