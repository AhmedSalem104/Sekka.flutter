import 'package:equatable/equatable.dart';

import '../../data/models/achievement_model.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/models/point_history_model.dart';

sealed class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

final class GamificationInitial extends GamificationState {
  const GamificationInitial();
}

final class GamificationLoading extends GamificationState {
  const GamificationLoading();
}

final class GamificationLoaded extends GamificationState {
  const GamificationLoaded({
    required this.challenges,
    required this.achievements,
    required this.totalPoints,
    required this.level,
    this.leaderboard,
    this.pointsHistory = const [],
    this.pointsHistoryPage = 1,
    this.hasMoreHistory = true,
    this.isClaimingId,
    this.isLoadingHistory = false,
    this.isLoadingLeaderboard = false,
  });

  final List<ChallengeModel> challenges;
  final List<AchievementModel> achievements;
  final int totalPoints;
  final int level;
  final LeaderboardModel? leaderboard;
  final List<PointHistoryModel> pointsHistory;
  final int pointsHistoryPage;
  final bool hasMoreHistory;
  final String? isClaimingId;
  final bool isLoadingHistory;
  final bool isLoadingLeaderboard;

  GamificationLoaded copyWith({
    List<ChallengeModel>? challenges,
    List<AchievementModel>? achievements,
    int? totalPoints,
    int? level,
    LeaderboardModel? leaderboard,
    List<PointHistoryModel>? pointsHistory,
    int? pointsHistoryPage,
    bool? hasMoreHistory,
    String? isClaimingId,
    bool? isLoadingHistory,
    bool? isLoadingLeaderboard,
  }) =>
      GamificationLoaded(
        challenges: challenges ?? this.challenges,
        achievements: achievements ?? this.achievements,
        totalPoints: totalPoints ?? this.totalPoints,
        level: level ?? this.level,
        leaderboard: leaderboard ?? this.leaderboard,
        pointsHistory: pointsHistory ?? this.pointsHistory,
        pointsHistoryPage: pointsHistoryPage ?? this.pointsHistoryPage,
        hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
        isClaimingId: isClaimingId,
        isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
        isLoadingLeaderboard:
            isLoadingLeaderboard ?? this.isLoadingLeaderboard,
      );

  @override
  List<Object?> get props => [
        challenges,
        achievements,
        totalPoints,
        level,
        leaderboard,
        pointsHistory,
        pointsHistoryPage,
        hasMoreHistory,
        isClaimingId,
        isLoadingHistory,
        isLoadingLeaderboard,
      ];
}

final class GamificationError extends GamificationState {
  const GamificationError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
