import '../../domain/entities/break_suggestion_entity.dart';

class BreakSuggestionModel extends BreakSuggestionEntity {
  const BreakSuggestionModel({
    required super.shouldBreak,
    required super.urgency,
    required super.suggestedDurationMinutes,
    required super.reason,
    required super.nearbySpots,
  });

  static int safeInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  factory BreakSuggestionModel.fromJson(Map<String, dynamic> json) {
    final spots = json['nearbySpots'];
    return BreakSuggestionModel(
      shouldBreak: (json['shouldBreak'] as bool?) ?? false,
      urgency: safeInt(json['urgency']),
      suggestedDurationMinutes: safeInt(json['suggestedDurationMinutes'], 15),
      reason: (json['reason'] as String?) ?? '',
      nearbySpots: spots is List
          ? spots.map((e) => e.toString()).toList()
          : <String>[],
    );
  }
}
