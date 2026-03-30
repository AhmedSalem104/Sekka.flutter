import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../domain/entities/daily_stats_entity.dart';
import '../../domain/entities/monthly_stats_entity.dart';
import '../../domain/entities/weekly_stats_entity.dart';
import '../../domain/repositories/statistics_repository.dart';

// ── Events ──

sealed class StatisticsEvent extends Equatable {
  const StatisticsEvent();
  @override
  List<Object?> get props => [];
}

final class StatisticsTabChanged extends StatisticsEvent {
  const StatisticsTabChanged(this.tab);
  final StatisticsTab tab;

  @override
  List<Object?> get props => [tab];
}

final class StatisticsLoadRequested extends StatisticsEvent {
  const StatisticsLoadRequested();
}

// ── Tab ──

enum StatisticsTab { daily, weekly, monthly }

// ── States ──

sealed class StatisticsState extends Equatable {
  const StatisticsState({required this.tab});
  final StatisticsTab tab;

  @override
  List<Object?> get props => [tab];
}

final class StatisticsInitial extends StatisticsState {
  const StatisticsInitial() : super(tab: StatisticsTab.weekly);
}

final class StatisticsLoading extends StatisticsState {
  const StatisticsLoading({required super.tab});
}

final class StatisticsLoaded extends StatisticsState {
  const StatisticsLoaded({
    required super.tab,
    this.daily,
    this.weekly,
    this.monthly,
  });

  final DailyStatsEntity? daily;
  final WeeklyStatsEntity? weekly;
  final MonthlyStatsEntity? monthly;

  @override
  List<Object?> get props => [tab, daily, weekly, monthly];
}

final class StatisticsEmpty extends StatisticsState {
  const StatisticsEmpty({required super.tab});
}

final class StatisticsError extends StatisticsState {
  const StatisticsError({required super.tab, required this.message});
  final String message;

  @override
  List<Object?> get props => [tab, message];
}

// ── BLoC ──

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsBloc({required StatisticsRepository repository})
      : _repository = repository,
        super(const StatisticsInitial()) {
    on<StatisticsTabChanged>(_onTabChanged);
    on<StatisticsLoadRequested>(_onLoad);
  }

  final StatisticsRepository _repository;

  DailyStatsEntity? _cachedDaily;
  WeeklyStatsEntity? _cachedWeekly;
  MonthlyStatsEntity? _cachedMonthly;

  Future<void> _onTabChanged(
    StatisticsTabChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    final tab = event.tab;

    // Return cached data if available
    switch (tab) {
      case StatisticsTab.daily when _cachedDaily != null:
        emit(StatisticsLoaded(tab: tab, daily: _cachedDaily));
        return;
      case StatisticsTab.weekly when _cachedWeekly != null:
        emit(StatisticsLoaded(tab: tab, weekly: _cachedWeekly));
        return;
      case StatisticsTab.monthly when _cachedMonthly != null:
        emit(StatisticsLoaded(tab: tab, monthly: _cachedMonthly));
        return;
      default:
        break;
    }

    await _loadTab(tab, emit);
  }

  Future<void> _onLoad(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    _cachedDaily = null;
    _cachedWeekly = null;
    _cachedMonthly = null;
    await _loadTab(state.tab, emit);
  }

  Future<void> _loadTab(
    StatisticsTab tab,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading(tab: tab));
    try {
      switch (tab) {
        case StatisticsTab.daily:
          _cachedDaily = await _repository.getDailyStats();
          emit(StatisticsLoaded(tab: tab, daily: _cachedDaily));
        case StatisticsTab.weekly:
          _cachedWeekly = await _repository.getWeeklyStats();
          emit(StatisticsLoaded(tab: tab, weekly: _cachedWeekly));
        case StatisticsTab.monthly:
          final now = DateTime.now();
          _cachedMonthly = await _repository.getMonthlyStats(
            month: now.month,
            year: now.year,
          );
          emit(StatisticsLoaded(tab: tab, monthly: _cachedMonthly));
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(StatisticsEmpty(tab: tab));
      } else {
        emit(StatisticsError(tab: tab, message: e.message));
      }
    }
  }
}
