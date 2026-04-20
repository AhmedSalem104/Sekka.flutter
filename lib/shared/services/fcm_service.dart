import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../network/api_constants.dart';
import '../storage/token_storage.dart';
import 'focus_mode_service.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log(
    'Background message: ${message.messageId}',
    name: 'FCM',
  );
}

class FcmService {
  FcmService._();
  static final instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  String? _token;

  String? get token => _token;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission();
    print('[FCM] Permission: ${settings.authorizationStatus}');

    _token = await _messaging.getToken();
    print('[FCM] Token: $_token');

    _messaging.onTokenRefresh.listen((newToken) {
      _token = newToken;
      dev.log('FCM Token refreshed: $newToken', name: 'FCM');
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Register FCM token with backend using a DIRECT Dio call (bypasses
  /// the auth interceptor to avoid the race condition where the interceptor
  /// clears tokens from a previous failed request).
  Future<void> registerWithBackend(TokenStorage tokenStorage, {
    int retryCount = 0,
  }) async {
    print('[FCM] registerWithBackend called (attempt ${retryCount + 1})');
    if (_token == null) {
      print('[FCM] SKIPPED — no FCM token!');
      return;
    }

    final jwt = await tokenStorage.getToken();
    if (jwt == null) {
      print('[FCM] SKIPPED — no JWT token!');
      if (retryCount < 3) {
        final delay = Duration(seconds: 5 * (retryCount + 1));
        print('[FCM] Will retry in ${delay.inSeconds}s...');
        Future.delayed(delay, () {
          registerWithBackend(tokenStorage, retryCount: retryCount + 1);
        });
      }
      return;
    }

    try {
      final dio = Dio();
      await dio.post(
        ApiConstants.registerDevice,
        data: {'token': _token!, 'platform': 1},
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('[FCM] Token registered with backend SUCCESS');
    } catch (e) {
      print('[FCM] FAILED to register: $e');
      if (retryCount < 3) {
        final delay = Duration(seconds: 5 * (retryCount + 1));
        print('[FCM] Will retry in ${delay.inSeconds}s...');
        Future.delayed(delay, () {
          registerWithBackend(tokenStorage, retryCount: retryCount + 1);
        });
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (FocusModeService.instance.shouldBlockNotification()) {
      print('[FCM] Blocked by focus mode');
      return;
    }

    final String title = message.notification?.title ??
        (message.data['title'] as String?) ?? '';
    final String body = message.notification?.body ??
        (message.data['body'] as String?) ?? '';
    print('[FCM] Foreground message: $title — $body');

    if (title.isNotEmpty || body.isNotEmpty) {
      LocalNotificationService.instance.show(
        title: title,
        body: body,
        payload: message.data.toString(),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    dev.log(
      'Opened app from notification: ${message.data}',
      name: 'FCM',
    );
  }
}
