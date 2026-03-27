import 'package:equatable/equatable.dart';

class CashStatusEntity extends Equatable {
  const CashStatusEntity({
    required this.cashOnHand,
    required this.threshold,
    required this.percentage,
    required this.alertLevel,
    required this.suggestedAction,
  });

  final double cashOnHand;
  final double threshold;
  final double percentage;
  final String alertLevel; // safe, warning, danger, critical
  final String suggestedAction;

  bool get isSafe => alertLevel == 'safe';
  bool get isWarning => alertLevel == 'warning';
  bool get isDanger => alertLevel == 'danger';
  bool get isCritical => alertLevel == 'critical';

  @override
  List<Object?> get props => [cashOnHand, threshold, percentage, alertLevel];
}
