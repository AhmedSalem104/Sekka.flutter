import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/offline/offline_queue_service.dart';
import '../../../../shared/offline/queue_operation.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../data/models/break_model.dart';
import '../../domain/entities/break_entity.dart';
import '../../domain/entities/break_suggestion_entity.dart';
import '../../domain/repositories/break_repository.dart';

part 'break_event.dart';
part 'break_state.dart';

class BreakBloc extends HydratedBloc<BreakEvent, BreakState> {
  BreakBloc({required BreakRepository repository})
      : _repository = repository,
        super(const BreakInitial()) {
    on<BreakCheckRequested>(_onCheck);
    on<BreakStartRequested>(_onStart);
    on<BreakEndRequested>(_onEnd);
    on<BreakHistoryRequested>(_onHistory);
    on<BreakHistoryNextPage>(_onHistoryNextPage);
  }

  final BreakRepository _repository;

  Future<void> _onCheck(
    BreakCheckRequested event,
    Emitter<BreakState> emit,
  ) async {
    emit(const BreakCheckLoading());
    try {
      final results = await Future.wait([
        _repository.getSuggestion(),
        _repository.getActiveBreak(),
      ]);
      emit(BreakCheckLoaded(
        suggestion: results[0] as BreakSuggestionEntity,
        activeBreak: results[1] as BreakEntity?,
      ));
    } on ApiException {
      // Silently emit empty loaded so home screen doesn't break
      emit(const BreakCheckLoaded());
    }
  }

  Future<void> _onStart(
    BreakStartRequested event,
    Emitter<BreakState> emit,
  ) async {
    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.breakStart,
        orderId: '',
        payload: {
          'energyBefore': event.energyBefore,
          'locationDescription': event.locationDescription,
        },
      );
      emit(BreakError(message: AppStrings.savedOffline));
      return;
    }

    emit(const BreakStarting());
    try {
      final breakEntity = await _repository.startBreak(
        energyBefore: event.energyBefore,
        locationDescription: event.locationDescription,
      );
      emit(BreakStarted(breakEntity: breakEntity));
    } on ApiException catch (e) {
      emit(BreakError(message: e.message));
    }
  }

  Future<void> _onEnd(
    BreakEndRequested event,
    Emitter<BreakState> emit,
  ) async {
    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.breakEnd,
        orderId: '',
        payload: {'energyAfter': event.energyAfter},
      );
      emit(BreakError(message: AppStrings.savedOffline));
      return;
    }

    emit(const BreakEnding());
    try {
      final breakEntity = await _repository.endBreak(
        energyAfter: event.energyAfter,
      );
      emit(BreakEnded(breakEntity: breakEntity));
    } on ApiException catch (e) {
      emit(BreakError(message: e.message));
    }
  }

  Future<void> _onHistory(
    BreakHistoryRequested event,
    Emitter<BreakState> emit,
  ) async {
    final current = state;
    if (current is! BreakHistoryLoaded) {
      emit(const BreakHistoryLoading());
    }
    try {
      final breaks = await _repository.getHistory(page: 1);
      emit(BreakHistoryLoaded(
        breaks: breaks,
        hasMore: breaks.length >= 20,
        currentPage: 1,
      ));
    } on ApiException catch (e) {
      if (current is! BreakHistoryLoaded) emit(BreakError(message: e.message));
    }
  }

  Future<void> _onHistoryNextPage(
    BreakHistoryNextPage event,
    Emitter<BreakState> emit,
  ) async {
    final current = state;
    if (current is! BreakHistoryLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final breaks = await _repository.getHistory(page: nextPage);
      emit(current.copyWith(
        breaks: [...current.breaks, ...breaks],
        hasMore: breaks.length >= 20,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  // ── Hydration ──

  @override
  BreakState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'history') {
        final breaks = (json['breaks'] as List<dynamic>)
            .map((b) => BreakModel.fromJson(
                  Map<String, dynamic>.from(b as Map),
                ))
            .toList();
        return BreakHistoryLoaded(
          breaks: breaks,
          hasMore: json['hasMore'] as bool? ?? false,
          currentPage: json['currentPage'] as int? ?? 1,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(BreakState state) {
    if (state is BreakHistoryLoaded) {
      return {
        'type': 'history',
        'breaks': state.breaks
            .whereType<BreakModel>()
            .map((b) => b.toJson())
            .toList(),
        'hasMore': state.hasMore,
        'currentPage': state.currentPage,
      };
    }
    return null;
  }
}
