import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/paginated_response.dart';
import '../models/achievement_model.dart';
import '../models/challenge_model.dart';
import '../models/leaderboard_model.dart';
import '../models/point_history_model.dart';

class GamificationRepository {
  const GamificationRepository(this._dio);

  final Dio _dio;

  /// GET /gamification/challenges
  Future<ApiResult<List<ChallengeModel>>> getChallenges() =>
      ApiHelper.execute(
        () => _dio.get(ApiConstants.gamificationChallenges),
        parser: (data) => (data as List<dynamic>)
            .map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// GET /gamification/achievements
  Future<ApiResult<List<AchievementModel>>> getAchievements() =>
      ApiHelper.execute(
        () => _dio.get(ApiConstants.gamificationAchievements),
        parser: (data) => (data as List<dynamic>)
            .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// GET /gamification/leaderboard?period={period}
  Future<ApiResult<LeaderboardModel>> getLeaderboard({
    String period = 'monthly',
  }) =>
      ApiHelper.execute(
        () => _dio.get(
          ApiConstants.gamificationLeaderboard,
          queryParameters: {'period': period},
        ),
        parser: (data) =>
            LeaderboardModel.fromJson(data as Map<String, dynamic>),
      );

  /// POST /gamification/challenges/{challengeId}/claim
  Future<ApiResult<void>> claimChallenge(String challengeId) =>
      ApiHelper.execute(
        () => _dio.post(ApiConstants.gamificationClaimChallenge(challengeId)),
        parser: (_) {},
      );

  /// GET /gamification/points/history?Page={page}&PageSize={pageSize}
  Future<ApiResult<PaginatedResponse<PointHistoryModel>>> getPointsHistory({
    int page = 1,
    int pageSize = 20,
  }) =>
      ApiHelper.execute(
        () => _dio.get(
          ApiConstants.gamificationPointsHistory,
          queryParameters: {'Page': page, 'PageSize': pageSize},
        ),
        parser: (data) => PaginatedResponse.fromJson(
          data as Map<String, dynamic>,
          fromJsonT: PointHistoryModel.fromJson,
        ),
      );

  /// GET /gamification/points/total
  Future<ApiResult<int>> getPointsTotal() => ApiHelper.execute(
        () => _dio.get(ApiConstants.gamificationPointsTotal),
        parser: (data) => data as int? ?? 0,
      );

  /// GET /gamification/level
  Future<ApiResult<int>> getLevel() => ApiHelper.execute(
        () => _dio.get(ApiConstants.gamificationLevel),
        parser: (data) => data as int? ?? 1,
      );
}
