import '../../domain/entities/daily_stats_entity.dart';
import '../../domain/entities/monthly_stats_entity.dart';
import '../../domain/entities/weekly_stats_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl({
    required StatisticsRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final StatisticsRemoteDataSource _remote;

  @override
  Future<DailyStatsEntity> getDailyStats({String? date}) =>
      _remote.getDailyStats(date: date);

  @override
  Future<WeeklyStatsEntity> getWeeklyStats({String? weekStart}) =>
      _remote.getWeeklyStats(weekStart: weekStart);

  @override
  Future<MonthlyStatsEntity> getMonthlyStats({int? month, int? year}) =>
      _remote.getMonthlyStats(month: month, year: year);
}
