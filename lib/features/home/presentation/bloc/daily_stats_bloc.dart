import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../../statistics/domain/entities/daily_stats_entity.dart';
import '../../../statistics/domain/repositories/statistics_repository.dart';

// ── Events ──

sealed class DailyStatsEvent extends Equatable {
  const DailyStatsEvent();
  @override
  List<Object?> get props => [];
}

final class DailyStatsLoadRequested extends DailyStatsEvent {
  const DailyStatsLoadRequested();
}

// ── States ──

sealed class DailyStatsState extends Equatable {
  const DailyStatsState();
  @override
  List<Object?> get props => [];
}

final class DailyStatsInitial extends DailyStatsState {
  const DailyStatsInitial();
}

final class DailyStatsLoading extends DailyStatsState {
  const DailyStatsLoading();
}

final class DailyStatsLoaded extends DailyStatsState {
  const DailyStatsLoaded(this.stats);
  final DailyStatsEntity stats;

  @override
  List<Object?> get props => [stats];
}

final class DailyStatsError extends DailyStatsState {
  const DailyStatsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──

class DailyStatsBloc extends Bloc<DailyStatsEvent, DailyStatsState> {
  DailyStatsBloc({required StatisticsRepository repository})
      : _repository = repository,
        super(const DailyStatsInitial()) {
    on<DailyStatsLoadRequested>(_onLoad);
  }

  final StatisticsRepository _repository;

  Future<void> _onLoad(
    DailyStatsLoadRequested event,
    Emitter<DailyStatsState> emit,
  ) async {
    emit(const DailyStatsLoading());
    try {
      final stats = await _repository.getDailyStats();
      emit(DailyStatsLoaded(stats));
    } on ApiException catch (e) {
      emit(DailyStatsError(e.message));
    }
  }
}
