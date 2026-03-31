import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../data/models/daily_stats_model.dart';
import '../../data/models/monthly_stats_model.dart';
import '../../data/models/weekly_stats_model.dart';
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

class StatisticsBloc extends HydratedBloc<StatisticsEvent, StatisticsState> {
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
    final current = state;
    if (current is! StatisticsLoaded) {
      emit(StatisticsLoading(tab: tab));
    }
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
      if (current is! StatisticsLoaded) {
        if (e.statusCode == 404) {
          emit(StatisticsEmpty(tab: tab));
        } else {
          emit(StatisticsError(tab: tab, message: e.message));
        }
      }
    }
  }

  // ── Hydration ──

  @override
  StatisticsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final tabName = json['tab'] as String? ?? 'weekly';
        final tab = StatisticsTab.values.byName(tabName);
        final daily = json['daily'] != null
            ? DailyStatsModel.fromJson(Map<String, dynamic>.from(json['daily'] as Map))
            : null;
        final weekly = json['weekly'] != null
            ? WeeklyStatsModel.fromJson(Map<String, dynamic>.from(json['weekly'] as Map))
            : null;
        final monthly = json['monthly'] != null
            ? MonthlyStatsModel.fromJson(Map<String, dynamic>.from(json['monthly'] as Map))
            : null;
        _cachedDaily = daily;
        _cachedWeekly = weekly;
        _cachedMonthly = monthly;
        return StatisticsLoaded(tab: tab, daily: daily, weekly: weekly, monthly: monthly);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(StatisticsState state) {
    if (state is StatisticsLoaded) {
      return {
        'type': 'loaded',
        'tab': state.tab.name,
        'daily': state.daily is DailyStatsModel
            ? (state.daily! as DailyStatsModel).toJson()
            : null,
        'weekly': state.weekly is WeeklyStatsModel
            ? (state.weekly! as WeeklyStatsModel).toJson()
            : null,
        'monthly': state.monthly is MonthlyStatsModel
            ? (state.monthly! as MonthlyStatsModel).toJson()
            : null,
      };
    }
    return null;
  }
}
