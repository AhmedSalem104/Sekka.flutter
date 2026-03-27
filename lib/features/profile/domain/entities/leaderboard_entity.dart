import 'package:equatable/equatable.dart';

class LeaderboardEntity extends Equatable {
  const LeaderboardEntity({
    required this.myRank,
    required this.myPoints,
    required this.topDrivers,
  });

  final int myRank;
  final int myPoints;
  final List<TopDriverEntity> topDrivers;

  @override
  List<Object?> get props => [myRank, myPoints, topDrivers];
}

class TopDriverEntity extends Equatable {
  const TopDriverEntity({
    required this.id,
    required this.name,
    required this.points,
    required this.rank,
    required this.profileImageUrl,
  });

  final String id;
  final String name;
  final int points;
  final int rank;
  final String? profileImageUrl;

  @override
  List<Object?> get props => [id, name, points, rank, profileImageUrl];
}
