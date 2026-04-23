import 'dart:async';

/// Lightweight event bus for refreshing the notification badge count.
/// Any bloc/service can call [trigger] after an action that creates
/// a notification on the backend.
class NotificationBadgeRefresh {
  NotificationBadgeRefresh._();

  static final _controller = StreamController<void>.broadcast();

  static Stream<void> get stream => _controller.stream;

  static void trigger() => _controller.add(null);
}
