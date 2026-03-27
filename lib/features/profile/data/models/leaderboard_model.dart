import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.myRank,
    required super.myPoints,
    required super.topDrivers,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      myRank: json['myRank'] as int? ?? 0,
      myPoints: json['myPoints'] as int? ?? 0,
      topDrivers: (json['topDrivers'] as List<dynamic>?)
              ?.map(
                (e) => TopDriverModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class TopDriverModel extends TopDriverEntity {
  const TopDriverModel({
    required super.id,
    required super.name,
    required super.points,
    required super.rank,
    required super.profileImageUrl,
  });

  factory TopDriverModel.fromJson(Map<String, dynamic> json) {
    return TopDriverModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}
