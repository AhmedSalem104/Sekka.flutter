import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../../../shared/offline/offline_queue_service.dart';
import '../../../../shared/offline/queue_operation.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc
    extends HydratedBloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({required NotificationRepository repository})
      : _repository = repository,
        super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationsRefreshRequested>(_onRefreshRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationsMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationReceived>(_onNotificationReceived);
  }

  final NotificationRepository _repository;

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    // Only show loading if no cached data
    if (state is! NotificationsLoaded) {
      emit(const NotificationsLoading());
    }

    final result = await _repository.getNotifications();

    switch (result) {
      case ApiSuccess(:final data):
        emit(NotificationsLoaded(
          notifications: data.items,
          totalCount: data.totalCount,
          hasMore: data.hasNextPage,
          currentPage: data.page,
        ));
      case ApiFailure(:final error):
        // Keep cached data on failure
        if (state is! NotificationsLoaded) {
          emit(NotificationsError(error.arabicMessage));
        }
    }
  }

  Future<void> _onRefreshRequested(
    NotificationsRefreshRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _repository.getNotifications();

    switch (result) {
      case ApiSuccess(:final data):
        emit(NotificationsLoaded(
          notifications: data.items,
          totalCount: data.totalCount,
          hasMore: data.hasNextPage,
          currentPage: data.page,
        ));
      case ApiFailure():
        break; // Keep existing cached state on refresh failure
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.notifications
        .map((n) => n.id == event.id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(NotificationsLoaded(
      notifications: updated,
      totalCount: current.totalCount,
      hasMore: current.hasMore,
      currentPage: current.currentPage,
    ));

    if (ConnectivityService.instance.isOnline) {
      await _repository.markAsRead(event.id);
    } else {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.notificationRead,
        orderId: event.id,
        payload: {'notificationId': event.id},
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationsMarkAllAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(NotificationsLoaded(
      notifications: updated,
      totalCount: current.totalCount,
      hasMore: current.hasMore,
      currentPage: current.currentPage,
    ));

    if (ConnectivityService.instance.isOnline) {
      await _repository.markAllAsRead();
    } else {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.notificationReadAll,
        orderId: '',
        payload: {},
      );
    }
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    final current = state;
    if (current is NotificationsLoaded) {
      emit(NotificationsLoaded(
        notifications: [event.notification, ...current.notifications],
        totalCount: current.totalCount + 1,
        hasMore: current.hasMore,
        currentPage: current.currentPage,
      ));
    }
  }

  // ── Hydration ──

  @override
  NotificationsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final notifications = (json['notifications'] as List<dynamic>)
            .map((n) => NotificationModel.fromJson(
                  Map<String, dynamic>.from(n as Map),
                ))
            .toList();
        return NotificationsLoaded(
          notifications: notifications,
          totalCount: json['totalCount'] as int? ?? notifications.length,
          hasMore: json['hasMore'] as bool? ?? false,
          currentPage: json['currentPage'] as int? ?? 1,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(NotificationsState state) {
    if (state is NotificationsLoaded) {
      return {
        'type': 'loaded',
        'notifications':
            state.notifications.map((n) => n.toJson()).toList(),
        'totalCount': state.totalCount,
        'hasMore': state.hasMore,
        'currentPage': state.currentPage,
      };
    }
    return null;
  }
}
