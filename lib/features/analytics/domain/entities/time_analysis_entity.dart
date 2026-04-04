import 'package:equatable/equatable.dart';

class TimeAnalysisEntity extends Equatable {
  const TimeAnalysisEntity({
    required this.hour,
    required this.dayOfWeek,
    required this.totalOrders,
    required this.averageEarnings,
  });

  final int hour;
  final String dayOfWeek;
  final int totalOrders;
  final double averageEarnings;

  @override
  List<Object?> get props => [hour, dayOfWeek, totalOrders, averageEarnings];
}
