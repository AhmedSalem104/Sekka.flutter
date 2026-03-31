import 'package:equatable/equatable.dart';

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

final class SyncStatusRequested extends SyncEvent {
  const SyncStatusRequested();
}

final class SyncPushRequested extends SyncEvent {
  const SyncPushRequested();
}

final class SyncPullRequested extends SyncEvent {
  const SyncPullRequested();
}

final class SyncNowRequested extends SyncEvent {
  const SyncNowRequested();
}

final class SyncResolveConflictRequested extends SyncEvent {
  const SyncResolveConflictRequested({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

final class SyncClearMessage extends SyncEvent {
  const SyncClearMessage();
}
