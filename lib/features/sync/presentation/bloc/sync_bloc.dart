import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../data/models/sync_models.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({required SyncRepository repository})
      : _repository = repository,
        super(const SyncInitial()) {
    on<SyncStatusRequested>(_onStatusLoad);
    on<SyncPushRequested>(_onPush);
    on<SyncPullRequested>(_onPull);
    on<SyncNowRequested>(_onSyncNow);
    on<SyncResolveConflictRequested>(_onResolveConflict);
    on<SyncClearMessage>(_onClearMessage);
    on<SyncConnectivityChanged>(_onConnectivityChanged);

    // Listen to real-time connectivity changes
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.isNotEmpty &&
          !results.every((r) => r == ConnectivityResult.none);
      add(SyncConnectivityChanged(isOnline: isOnline));
    });
  }

  final SyncRepository _repository;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }

  void _onConnectivityChanged(
    SyncConnectivityChanged event,
    Emitter<SyncState> emit,
  ) {
    final current = state;
    final loaded = current is SyncLoaded ? current : const SyncLoaded();
    final oldStatus = loaded.status;

    emit(loaded.copyWith(
      status: () => SyncStatusModel(
        lastSyncAt: oldStatus?.lastSyncAt,
        pendingChanges: oldStatus?.pendingChanges ?? 0,
        conflictsCount: oldStatus?.conflictsCount ?? 0,
        isOnline: event.isOnline,
      ),
    ));

    // Auto-sync when back online
    if (event.isOnline && (oldStatus?.pendingChanges ?? 0) > 0) {
      add(const SyncNowRequested());
    }
  }

  Future<void> _onStatusLoad(
    SyncStatusRequested event,
    Emitter<SyncState> emit,
  ) async {
    try {
      final status = await _repository.getStatus();
      final current = state;
      if (current is SyncLoaded) {
        emit(current.copyWith(status: () => status));
      } else {
        emit(SyncLoaded(status: status));
      }
    } on ApiException catch (e) {
      emit(SyncError(e.message));
    } catch (_) {
      emit(SyncError(AppStrings.unknownError));
    }
  }

  Future<void> _onPush(
    SyncPushRequested event,
    Emitter<SyncState> emit,
  ) async {
    final current = state;
    final loaded = current is SyncLoaded ? current : const SyncLoaded();

    emit(loaded.copyWith(isSyncing: true, actionMessage: () => null));

    try {
      final result = await _repository.push();
      final status = await _repository.getStatus();
      emit(loaded.copyWith(
        isSyncing: false,
        lastPushResult: () => result,
        status: () => status,
        actionMessage: () => AppStrings.syncComplete,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isSyncing: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isSyncing: false,
        actionMessage: () => AppStrings.syncFailed,
        isActionError: true,
      ));
    }
  }

  Future<void> _onPull(
    SyncPullRequested event,
    Emitter<SyncState> emit,
  ) async {
    final current = state;
    final loaded = current is SyncLoaded ? current : const SyncLoaded();

    emit(loaded.copyWith(isSyncing: true, actionMessage: () => null));

    try {
      final result = await _repository.pull();
      final status = await _repository.getStatus();
      emit(loaded.copyWith(
        isSyncing: false,
        lastPullResult: () => result,
        status: () => status,
        actionMessage: () => AppStrings.syncComplete,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isSyncing: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isSyncing: false,
        actionMessage: () => AppStrings.syncFailed,
        isActionError: true,
      ));
    }
  }

  Future<void> _onSyncNow(
    SyncNowRequested event,
    Emitter<SyncState> emit,
  ) async {
    final current = state;
    final loaded = current is SyncLoaded ? current : const SyncLoaded();

    emit(loaded.copyWith(isSyncing: true, actionMessage: () => null));

    try {
      // Push first, then pull
      final pushResult = await _repository.push();
      final pullResult = await _repository.pull();
      final status = await _repository.getStatus();

      emit(loaded.copyWith(
        isSyncing: false,
        lastPushResult: () => pushResult,
        lastPullResult: () => pullResult,
        status: () => status,
        actionMessage: () => AppStrings.syncComplete,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isSyncing: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isSyncing: false,
        actionMessage: () => AppStrings.syncFailed,
        isActionError: true,
      ));
    }
  }

  Future<void> _onResolveConflict(
    SyncResolveConflictRequested event,
    Emitter<SyncState> emit,
  ) async {
    final current = state;
    if (current is! SyncLoaded) return;

    emit(current.copyWith(isSyncing: true, actionMessage: () => null));

    try {
      await _repository.resolveConflict(event.data);
      final status = await _repository.getStatus();
      emit(current.copyWith(
        isSyncing: false,
        status: () => status,
        actionMessage: () => AppStrings.syncComplete,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isSyncing: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isSyncing: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  void _onClearMessage(
    SyncClearMessage event,
    Emitter<SyncState> emit,
  ) {
    final current = state;
    if (current is SyncLoaded) {
      emit(current.copyWith(
        actionMessage: () => null,
        isActionError: false,
      ));
    }
  }
}
