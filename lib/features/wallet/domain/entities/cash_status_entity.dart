import 'package:equatable/equatable.dart';

class CashStatusEntity extends Equatable {
  const CashStatusEntity({
    required this.driverId,
    required this.cashOnHand,
    required this.cashAlertThreshold,
    required this.isOverThreshold,
    this.lastSettlementAt,
    required this.hoursSinceLastSettlement,
  });

  final String driverId;
  final double cashOnHand;
  final double cashAlertThreshold;
  final bool isOverThreshold;
  final DateTime? lastSettlementAt;
  final int hoursSinceLastSettlement;

  /// Derive alert level from API data.
  String get alertLevel {
    if (!isOverThreshold) return 'safe';
    if (hoursSinceLastSettlement > 24) return 'critical';
    if (hoursSinceLastSettlement > 8) return 'danger';
    return 'warning';
  }

  bool get isSafe => alertLevel == 'safe';
  bool get isWarning => alertLevel == 'warning';
  bool get isDanger => alertLevel == 'danger';
  bool get isCritical => alertLevel == 'critical';

  /// Percentage for the progress bar (0.0 - 1.0).
  double get percentage {
    if (cashAlertThreshold <= 0) return isOverThreshold ? 1.0 : 0.0;
    return (cashOnHand / cashAlertThreshold).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        driverId,
        cashOnHand,
        cashAlertThreshold,
        isOverThreshold,
        lastSettlementAt,
        hoursSinceLastSettlement,
      ];
}
