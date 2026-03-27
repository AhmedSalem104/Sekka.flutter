import '../entities/daily_stats_entity.dart';
import '../entities/monthly_stats_entity.dart';
import '../entities/weekly_stats_entity.dart';

abstract class StatisticsRepository {
  Future<DailyStatsEntity> getDailyStats({String? date});

  Future<WeeklyStatsEntity> getWeeklyStats({String? weekStart});

  Future<MonthlyStatsEntity> getMonthlyStats({int? month, int? year});
}
