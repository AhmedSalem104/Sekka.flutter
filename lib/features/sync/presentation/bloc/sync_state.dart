import 'package:equatable/equatable.dart';

import '../../data/models/sync_models.dart';

sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

final class SyncInitial extends SyncState {
  const SyncInitial();
}

final class SyncLoaded extends SyncState {
  const SyncLoaded({
    this.status,
    this.isSyncing = false,
    this.actionMessage,
    this.isActionError = false,
    this.lastPushResult,
    this.lastPullResult,
  });

  final SyncStatusModel? status;
  final bool isSyncing;
  final String? actionMessage;
  final bool isActionError;
  final SyncPushResult? lastPushResult;
  final SyncPullResult? lastPullResult;

  SyncLoaded copyWith({
    SyncStatusModel? Function()? status,
    bool? isSyncing,
    String? Function()? actionMessage,
    bool? isActionError,
    SyncPushResult? Function()? lastPushResult,
    SyncPullResult? Function()? lastPullResult,
  }) {
    return SyncLoaded(
      status: status != null ? status() : this.status,
      isSyncing: isSyncing ?? this.isSyncing,
      actionMessage:
          actionMessage != null ? actionMessage() : this.actionMessage,
      isActionError: isActionError ?? this.isActionError,
      lastPushResult:
          lastPushResult != null ? lastPushResult() : this.lastPushResult,
      lastPullResult:
          lastPullResult != null ? lastPullResult() : this.lastPullResult,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isSyncing,
        actionMessage,
        isActionError,
        lastPushResult,
        lastPullResult,
      ];
}

final class SyncError extends SyncState {
  const SyncError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
