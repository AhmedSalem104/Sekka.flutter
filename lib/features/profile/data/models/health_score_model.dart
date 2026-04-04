import '../../domain/entities/health_score_entity.dart';

class HealthScoreModel extends HealthScoreEntity {
  const HealthScoreModel({
    required super.overallScore,
    required super.successRateScore,
    required super.customerRatingScore,
    required super.commitmentScore,
    required super.activityScore,
    required super.cashHandlingScore,
    required super.status,
    required super.lastCalculatedAt,
    required super.trend,
  });

  factory HealthScoreModel.fromJson(Map<String, dynamic> json) {
    return HealthScoreModel(
      overallScore: json['overallScore'] as int? ?? 0,
      successRateScore: json['successRateScore'] as int? ?? 0,
      customerRatingScore: json['customerRatingScore'] as int? ?? 0,
      commitmentScore: json['commitmentScore'] as int? ?? 0,
      activityScore: json['activityScore'] as int? ?? 0,
      cashHandlingScore: json['cashHandlingScore'] as int? ?? 0,
      status: json['status'] as String? ?? 'Unknown',
      lastCalculatedAt: json['lastCalculatedAt'] != null
          ? DateTime.tryParse(json['lastCalculatedAt'] as String)
          : null,
      trend: json['trend'] as String? ?? 'stable',
    );
  }

  Map<String, dynamic> toJson() => {
        'overallScore': overallScore,
        'successRateScore': successRateScore,
        'customerRatingScore': customerRatingScore,
        'commitmentScore': commitmentScore,
        'activityScore': activityScore,
        'cashHandlingScore': cashHandlingScore,
        'status': status,
        'lastCalculatedAt': lastCalculatedAt?.toIso8601String(),
        'trend': trend,
      };
}
