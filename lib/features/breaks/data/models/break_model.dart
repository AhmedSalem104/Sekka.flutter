import '../../domain/entities/break_entity.dart';

class BreakModel extends BreakEntity {
  const BreakModel({
    required super.id,
    required super.startTime,
    super.endTime,
    super.durationMinutes,
    required super.locationDescription,
    required super.energyBefore,
    super.energyAfter,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationMinutes': durationMinutes,
        'locationDescription': locationDescription,
        'energyBefore': energyBefore,
        'energyAfter': energyAfter,
      };

  factory BreakModel.fromJson(Map<String, dynamic> json) {
    return BreakModel(
      id: (json['id'] as String?) ?? '',
      startTime: DateTime.tryParse(
            (json['startTime'] as String?) ?? '',
          ) ??
          DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int?,
      locationDescription: (json['locationDescription'] as String?) ?? '',
      energyBefore: (json['energyBefore'] as int?) ?? 3,
      energyAfter: json['energyAfter'] as int?,
    );
  }
}
