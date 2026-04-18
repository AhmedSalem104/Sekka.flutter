import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import 'focus_mode_service.dart';

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
    dev.log(
      'Notification permission: ${settings.authorizationStatus}',
      name: 'FCM',
    );

    _token = await _messaging.getToken();
    dev.log('FCM Token: $_token', name: 'FCM');

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

  Future<void> registerWithBackend(AuthRepositoryImpl authRepository) async {
    if (_token == null) return;
    try {
      await authRepository.registerDevice(
        fcmToken: _token!,
        platform: 1,
      );
      dev.log('FCM token registered with backend', name: 'FCM');
    } catch (e) {
      dev.log('Failed to register FCM token: $e', name: 'FCM');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (FocusModeService.instance.shouldBlockNotification()) {
      dev.log('FCM blocked (focus mode)', name: 'FCM');
      return;
    }
    dev.log(
      'Foreground message: ${message.notification?.title}',
      name: 'FCM',
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    dev.log(
      'Opened app from notification: ${message.data}',
      name: 'FCM',
    );
  }
}
