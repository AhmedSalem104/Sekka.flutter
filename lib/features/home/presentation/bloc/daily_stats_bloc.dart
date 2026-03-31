import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../../statistics/data/models/daily_stats_model.dart';
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

/// Silent refresh — no loading spinner, keeps existing data while fetching.
final class DailyStatsRefreshRequested extends DailyStatsEvent {
  const DailyStatsRefreshRequested();
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
  const DailyStatsLoaded(this.stats, {this.isRefreshing = false});
  final DailyStatsEntity stats;
  final bool isRefreshing;

  DailyStatsLoaded copyWith({DailyStatsEntity? stats, bool? isRefreshing}) =>
      DailyStatsLoaded(
        stats ?? this.stats,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [stats, isRefreshing];
}

final class DailyStatsError extends DailyStatsState {
  const DailyStatsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──

class DailyStatsBloc
    extends HydratedBloc<DailyStatsEvent, DailyStatsState> {
  DailyStatsBloc({required StatisticsRepository repository})
      : _repository = repository,
        super(const DailyStatsInitial()) {
    on<DailyStatsLoadRequested>(_onLoad);
    on<DailyStatsRefreshRequested>(_onRefresh);
  }

  final StatisticsRepository _repository;

  Future<void> _onLoad(
    DailyStatsLoadRequested event,
    Emitter<DailyStatsState> emit,
  ) async {
    final current = state;
    if (current is! DailyStatsLoaded) {
      emit(const DailyStatsLoading());
    }
    try {
      final stats = await _repository.getDailyStats();
      emit(DailyStatsLoaded(stats));
    } on ApiException catch (e) {
      if (current is! DailyStatsLoaded) emit(DailyStatsError(e.message));
    }
  }

  Future<void> _onRefresh(
    DailyStatsRefreshRequested event,
    Emitter<DailyStatsState> emit,
  ) async {
    final current = state;
    if (current is DailyStatsLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      final stats = await _repository.getDailyStats();
      emit(DailyStatsLoaded(stats));
    } on ApiException {
      // Keep existing data on failure
      if (current is DailyStatsLoaded) {
        emit(current.copyWith(isRefreshing: false));
      }
    }
  }

  // ── Hydration ──

  @override
  DailyStatsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final stats = DailyStatsModel.fromJson(
          Map<String, dynamic>.from(json['stats'] as Map),
        );
        return DailyStatsLoaded(stats);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(DailyStatsState state) {
    if (state is DailyStatsLoaded) {
      final model = state.stats;
      if (model is DailyStatsModel) {
        return {'type': 'loaded', 'stats': model.toJson()};
      }
    }
    return null;
  }
}
