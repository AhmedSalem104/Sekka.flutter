import 'package:equatable/equatable.dart';

class CancellationReportEntity extends Equatable {
  const CancellationReportEntity({
    required this.reason,
    required this.count,
    required this.percentage,
  });

  final String reason;
  final int count;
  final double percentage;

  @override
  List<Object?> get props => [reason, count, percentage];
}
