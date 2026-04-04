import 'package:equatable/equatable.dart';

class LeaderboardModel extends Equatable {
  const LeaderboardModel({
    required this.myRank,
    required this.myPoints,
    required this.topDrivers,
  });

  final int myRank;
  final int myPoints;
  final List<LeaderboardEntryModel> topDrivers;

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      myRank: json['myRank'] as int? ?? 0,
      myPoints: json['myPoints'] as int? ?? 0,
      topDrivers: (json['topDrivers'] as List<dynamic>?)
              ?.map((e) =>
                  LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [myRank, myPoints, topDrivers];
}

class LeaderboardEntryModel extends Equatable {
  const LeaderboardEntryModel({
    required this.rank,
    required this.driverName,
    required this.points,
    required this.level,
    required this.ordersThisMonth,
  });

  final int rank;
  final String driverName;
  final int points;
  final int level;
  final int ordersThisMonth;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int? ?? 0,
      driverName: json['driverName'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      ordersThisMonth: json['ordersThisMonth'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [rank, driverName, points, level, ordersThisMonth];
}
