import '../entities/daily_stats_entity.dart';
import '../entities/heatmap_stats_entity.dart';
import '../entities/monthly_stats_entity.dart';
import '../entities/weekly_stats_entity.dart';

abstract class StatisticsRepository {
  Future<DailyStatsEntity> getTodayStats();

  Future<DailyStatsEntity> getDailyStats({String? date});

  Future<WeeklyStatsEntity> getWeeklyStats({String? weekStart});

  Future<MonthlyStatsEntity> getMonthlyStats({int? month, int? year});

  Future<List<HeatmapCellEntity>> getHeatmap();
}
