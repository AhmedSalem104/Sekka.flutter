import 'package:equatable/equatable.dart';

class ShiftSummaryEntity extends Equatable {
  const ShiftSummaryEntity({
    required this.totalShifts,
    required this.totalHoursWorked,
    required this.totalOrdersCompleted,
    required this.totalEarnings,
    required this.totalDistanceKm,
    required this.averageShiftDurationHours,
  });

  final int totalShifts;
  final double totalHoursWorked;
  final int totalOrdersCompleted;
  final double totalEarnings;
  final double totalDistanceKm;
  final double averageShiftDurationHours;

  @override
  List<Object?> get props => [
        totalShifts,
        totalHoursWorked,
        totalOrdersCompleted,
        totalEarnings,
        totalDistanceKm,
        averageShiftDurationHours,
      ];
}
