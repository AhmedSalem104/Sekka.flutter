import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    required this.totalCount,
    this.hasMore = true,
    this.currentPage = 1,
  });

  final List<NotificationModel> notifications;
  final int totalCount;
  final bool hasMore;
  final int currentPage;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications, totalCount, hasMore, currentPage];
}

final class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
