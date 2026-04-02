import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

final class NotificationsLoadRequested extends NotificationsEvent {
  const NotificationsLoadRequested();
}

final class NotificationsRefreshRequested extends NotificationsEvent {
  const NotificationsRefreshRequested();
}

final class NotificationMarkAsRead extends NotificationsEvent {
  const NotificationMarkAsRead(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

final class NotificationsMarkAllAsRead extends NotificationsEvent {
  const NotificationsMarkAllAsRead();
}

final class NotificationReceived extends NotificationsEvent {
  const NotificationReceived(this.notification);
  final NotificationModel notification;
  @override
  List<Object?> get props => [notification];
}
