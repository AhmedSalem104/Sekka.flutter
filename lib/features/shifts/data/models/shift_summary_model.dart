import '../../domain/entities/shift_summary_entity.dart';

class ShiftSummaryModel extends ShiftSummaryEntity {
  const ShiftSummaryModel({
    required super.totalShifts,
    required super.totalHoursWorked,
    required super.totalOrdersCompleted,
    required super.totalEarnings,
    required super.totalDistanceKm,
    required super.averageShiftDurationHours,
  });

  factory ShiftSummaryModel.fromJson(Map<String, dynamic> json) {
    return ShiftSummaryModel(
      totalShifts: json['totalShifts'] as int? ?? 0,
      totalHoursWorked: (json['totalHoursWorked'] as num?)?.toDouble() ?? 0,
      totalOrdersCompleted: json['totalOrdersCompleted'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      averageShiftDurationHours:
          (json['averageShiftDurationHours'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalShifts': totalShifts,
        'totalHoursWorked': totalHoursWorked,
        'totalOrdersCompleted': totalOrdersCompleted,
        'totalEarnings': totalEarnings,
        'totalDistanceKm': totalDistanceKm,
        'averageShiftDurationHours': averageShiftDurationHours,
      };
}
