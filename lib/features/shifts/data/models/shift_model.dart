import '../../domain/entities/shift_entity.dart';

class ShiftModel extends ShiftEntity {
  const ShiftModel({
    required super.id,
    required super.driverId,
    required super.status,
    required super.startTime,
    super.endTime,
    required super.startLatitude,
    required super.startLongitude,
    super.endLatitude,
    super.endLongitude,
    required super.ordersCompleted,
    required super.earningsTotal,
    required super.distanceKm,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      startLatitude: (json['startLatitude'] as num?)?.toDouble() ?? 0,
      startLongitude: (json['startLongitude'] as num?)?.toDouble() ?? 0,
      endLatitude: (json['endLatitude'] as num?)?.toDouble(),
      endLongitude: (json['endLongitude'] as num?)?.toDouble(),
      ordersCompleted: json['ordersCompleted'] as int? ?? 0,
      earningsTotal: (json['earningsTotal'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'driverId': driverId,
        'status': status,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'startLatitude': startLatitude,
        'startLongitude': startLongitude,
        'endLatitude': endLatitude,
        'endLongitude': endLongitude,
        'ordersCompleted': ordersCompleted,
        'earningsTotal': earningsTotal,
        'distanceKm': distanceKm,
      };
}
