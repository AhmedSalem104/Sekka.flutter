import 'package:equatable/equatable.dart';

class HealthScoreEntity extends Equatable {
  const HealthScoreEntity({
    required this.overallScore,
    required this.successRateScore,
    required this.customerRatingScore,
    required this.commitmentScore,
    required this.activityScore,
    required this.cashHandlingScore,
    required this.status,
    required this.lastCalculatedAt,
    required this.trend,
  });

  final int overallScore;
  final int successRateScore;
  final int customerRatingScore;
  final int commitmentScore;
  final int activityScore;
  final int cashHandlingScore;
  final String status;
  final DateTime? lastCalculatedAt;
  final String trend;

  @override
  List<Object?> get props => [
        overallScore,
        successRateScore,
        customerRatingScore,
        commitmentScore,
        activityScore,
        cashHandlingScore,
        status,
        lastCalculatedAt,
        trend,
      ];
}
