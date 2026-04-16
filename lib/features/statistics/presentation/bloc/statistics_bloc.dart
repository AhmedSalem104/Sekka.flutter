import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_exception.dart';
import '../../data/models/daily_stats_model.dart';
import '../../data/models/monthly_stats_model.dart';
import '../../data/models/weekly_stats_model.dart';
import '../../domain/entities/daily_stats_entity.dart';
import '../../domain/entities/heatmap_stats_entity.dart';
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

final class StatisticsDateChanged extends StatisticsEvent {
  const StatisticsDateChanged(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class StatisticsWeekChanged extends StatisticsEvent {
  const StatisticsWeekChanged(this.weekStart);
  final DateTime weekStart;

  @override
  List<Object?> get props => [weekStart];
}

// ── Tab ──

enum StatisticsTab { daily, weekly, monthly }

final class StatisticsHeatmapRequested extends StatisticsEvent {
  const StatisticsHeatmapRequested();
}

// ── States ──

sealed class StatisticsState extends Equatable {
  const StatisticsState({required this.tab});
  final StatisticsTab tab;

  @override
  List<Object?> get props => [tab];
}

final class StatisticsInitial extends StatisticsState {
  const StatisticsInitial() : super(tab: StatisticsTab.daily);
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
    this.heatmap,
    this.selectedDate,
    this.selectedWeekStart,
  });

  final DailyStatsEntity? daily;
  final WeeklyStatsEntity? weekly;
  final MonthlyStatsEntity? monthly;
  final List<HeatmapCellEntity>? heatmap;
  final DateTime? selectedDate;
  final DateTime? selectedWeekStart;

  StatisticsLoaded copyWith({
    StatisticsTab? tab,
    DailyStatsEntity? daily,
    WeeklyStatsEntity? weekly,
    MonthlyStatsEntity? monthly,
    List<HeatmapCellEntity>? heatmap,
    DateTime? selectedDate,
    DateTime? selectedWeekStart,
  }) =>
      StatisticsLoaded(
        tab: tab ?? this.tab,
        daily: daily ?? this.daily,
        weekly: weekly ?? this.weekly,
        monthly: monthly ?? this.monthly,
        heatmap: heatmap ?? this.heatmap,
        selectedDate: selectedDate ?? this.selectedDate,
        selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
      );

  @override
  List<Object?> get props => [
        tab,
        daily,
        weekly,
        monthly,
        heatmap,
        selectedDate,
        selectedWeekStart,
      ];
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
    on<StatisticsDateChanged>(_onDateChanged);
    on<StatisticsWeekChanged>(_onWeekChanged);
    on<StatisticsHeatmapRequested>(_onHeatmapRequested);
  }

  final StatisticsRepository _repository;

  DailyStatsEntity? _cachedDaily;
  WeeklyStatsEntity? _cachedWeekly;
  MonthlyStatsEntity? _cachedMonthly;
  List<HeatmapCellEntity>? _cachedHeatmap;
  DateTime? _selectedDate;
  DateTime? _selectedWeekStart;

  static DateTime _startOfWeek(DateTime d) {
    // Sekka business week: Saturday → Friday
    final day = DateTime(d.year, d.month, d.day);
    final offset = (day.weekday + 1) % 7; // Sat=0, Sun=1 ... Fri=6
    return day.subtract(Duration(days: offset));
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _onTabChanged(
    StatisticsTabChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    final tab = event.tab;

    switch (tab) {
      case StatisticsTab.daily when _cachedDaily != null:
        emit(_loadedState(tab: tab));
        return;
      case StatisticsTab.weekly when _cachedWeekly != null:
        emit(_loadedState(tab: tab));
        return;
      case StatisticsTab.monthly when _cachedMonthly != null:
        emit(_loadedState(tab: tab));
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
    _cachedHeatmap = null;
    await _loadTab(state.tab, emit);
  }

  Future<void> _onDateChanged(
    StatisticsDateChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    _selectedDate = event.date;
    _cachedDaily = null;
    await _loadTab(StatisticsTab.daily, emit);
  }

  Future<void> _onHeatmapRequested(
    StatisticsHeatmapRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    if (_cachedHeatmap != null) return;
    try {
      _cachedHeatmap = await _repository.getHeatmap();
      if (state is StatisticsLoaded) {
        emit(_loadedState(tab: state.tab));
      }
    } on ApiException {
      _cachedHeatmap = const [];
      if (state is StatisticsLoaded) {
        emit(_loadedState(tab: state.tab));
      }
    }
  }

  Future<void> _onWeekChanged(
    StatisticsWeekChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    _selectedWeekStart = _startOfWeek(event.weekStart);
    _cachedWeekly = null;
    await _loadTab(StatisticsTab.weekly, emit);
  }

  Future<void> _loadTab(
    StatisticsTab tab,
    Emitter<StatisticsState> emit,
  ) async {
    final current = state;
    if (current is! StatisticsLoaded) {
      emit(StatisticsLoading(tab: tab));
    } else {
      emit(current.copyWith(tab: tab));
    }
    try {
      switch (tab) {
        case StatisticsTab.daily:
          final selected = _selectedDate ?? DateTime.now();
          final isToday = _isSameDay(selected, DateTime.now());
          _cachedDaily = isToday
              ? await _repository.getTodayStats()
              : await _repository.getDailyStats(date: _formatDate(selected));
          _selectedDate = selected;
          emit(_loadedState(tab: tab));
        case StatisticsTab.weekly:
          final weekStart = _selectedWeekStart ?? _startOfWeek(DateTime.now());
          _cachedWeekly = await _repository.getWeeklyStats(
            weekStart: _formatDate(weekStart),
          );
          _selectedWeekStart = weekStart;
          emit(_loadedState(tab: tab));
        case StatisticsTab.monthly:
          final now = DateTime.now();
          _cachedMonthly = await _repository.getMonthlyStats(
            month: now.month,
            year: now.year,
          );
          emit(_loadedState(tab: tab));
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(StatisticsEmpty(tab: tab));
      } else {
        emit(StatisticsError(tab: tab, message: e.message));
      }
    }
  }

  StatisticsLoaded _loadedState({required StatisticsTab tab}) =>
      StatisticsLoaded(
        tab: tab,
        daily: _cachedDaily,
        weekly: _cachedWeekly,
        monthly: _cachedMonthly,
        heatmap: _cachedHeatmap,
        selectedDate: _selectedDate,
        selectedWeekStart: _selectedWeekStart,
      );

  static String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  // ── Hydration ──

  @override
  StatisticsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final tabName = json['tab'] as String? ?? 'daily';
        final tab = StatisticsTab.values.byName(tabName);
        final daily = json['daily'] != null
            ? DailyStatsModel.fromJson(
                Map<String, dynamic>.from(json['daily'] as Map))
            : null;
        final weekly = json['weekly'] != null
            ? WeeklyStatsModel.fromJson(
                Map<String, dynamic>.from(json['weekly'] as Map))
            : null;
        final monthly = json['monthly'] != null
            ? MonthlyStatsModel.fromJson(
                Map<String, dynamic>.from(json['monthly'] as Map))
            : null;
        _cachedDaily = daily;
        _cachedWeekly = weekly;
        _cachedMonthly = monthly;
        return StatisticsLoaded(
          tab: tab,
          daily: daily,
          weekly: weekly,
          monthly: monthly,
        );
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
