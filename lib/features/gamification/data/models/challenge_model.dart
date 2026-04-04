import 'package:equatable/equatable.dart';

class ChallengeModel extends Equatable {
  const ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.challengeType,
    required this.targetValue,
    required this.currentProgress,
    required this.progressPercentage,
    required this.rewardPoints,
    required this.badgeName,
    required this.isCompleted,
  });

  final String id;
  final String name;
  final String description;
  final int challengeType;
  final int targetValue;
  final int currentProgress;
  final double progressPercentage;
  final int rewardPoints;
  final String badgeName;
  final bool isCompleted;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        challengeType: json['challengeType'] as int? ?? 0,
        targetValue: json['targetValue'] as int? ?? 0,
        currentProgress: json['currentProgress'] as int? ?? 0,
        progressPercentage:
            (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
        rewardPoints: json['rewardPoints'] as int? ?? 0,
        badgeName: json['badgeName'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        challengeType,
        targetValue,
        currentProgress,
        progressPercentage,
        rewardPoints,
        badgeName,
        isCompleted,
      ];
}
