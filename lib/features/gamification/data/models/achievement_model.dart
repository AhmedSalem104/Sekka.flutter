import 'package:equatable/equatable.dart';

class AchievementModel extends Equatable {
  const AchievementModel({
    required this.id,
    required this.challengeName,
    required this.badgeName,
    this.badgeIconUrl,
    required this.pointsEarned,
    required this.completedAt,
  });

  final String id;
  final String challengeName;
  final String badgeName;
  final String? badgeIconUrl;
  final int pointsEarned;
  final DateTime completedAt;

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String? ?? '',
      challengeName: json['challengeName'] as String? ?? '',
      badgeName: json['badgeName'] as String? ?? '',
      badgeIconUrl: json['badgeIconUrl'] as String?,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        challengeName,
        badgeName,
        badgeIconUrl,
        pointsEarned,
        completedAt,
      ];
}
