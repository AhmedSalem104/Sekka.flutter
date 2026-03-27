import 'dart:convert';
import 'dart:developer' as dev;
import '../../features/notifications/data/models/notification_model.dart';
import '../storage/token_storage.dart';
import 'signalr_service.dart';

/// Real-time notification hub.
///
/// Events listened:
/// - `NewNotification` → new notification received
/// - `NotificationRead` → confirmation that notification was marked read
/// - `AllNotificationsRead` → confirmation all marked read
/// - `BroadcastMessage` → system-wide broadcast
/// - `SettlementApproved` → settlement approved
/// - `PaymentApproved` → payment approved
class NotificationHub {
  NotificationHub({required TokenStorage tokenStorage})
      : _service = SignalRService(
          hubName: 'notifications',
          tokenStorage: tokenStorage,
        );

  final SignalRService _service;

  void Function(NotificationModel notification)? onNewNotification;
  void Function(String notificationId)? onNotificationRead;
  void Function()? onAllNotificationsRead;
  void Function(Map<String, dynamic> data)? onBroadcast;

  Future<void> connect() async {
    await _service.connect();

    _service.on('NewNotification', (args) {
      if (args != null && args.isNotEmpty) {
        try {
          final data = args[0] is String
              ? jsonDecode(args[0] as String) as Map<String, dynamic>
              : args[0] as Map<String, dynamic>;
          final notification = NotificationModel.fromJson(data);
          onNewNotification?.call(notification);
        } catch (e) {
          dev.log('Error parsing NewNotification: $e', name: 'NotificationHub');
        }
      }
    });

    _service.on('NotificationRead', (args) {
      if (args != null && args.isNotEmpty) {
        onNotificationRead?.call(args[0] as String);
      }
    });

    _service.on('AllNotificationsRead', (args) {
      onAllNotificationsRead?.call();
    });

    _service.on('BroadcastMessage', (args) {
      if (args != null && args.isNotEmpty) {
        try {
          final data = args[0] is String
              ? jsonDecode(args[0] as String) as Map<String, dynamic>
              : args[0] as Map<String, dynamic>;
          onBroadcast?.call(data);
        } catch (e) {
          dev.log('Error parsing BroadcastMessage: $e', name: 'NotificationHub');
        }
      }
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _service.invoke('MarkAsRead', args: [notificationId]);
  }

  Future<void> markAllAsRead() async {
    await _service.invoke('MarkAllAsRead');
  }

  Future<void> disconnect() async {
    await _service.disconnect();
  }
}
