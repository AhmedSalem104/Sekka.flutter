import '../../domain/entities/break_suggestion_entity.dart';

class BreakSuggestionModel extends BreakSuggestionEntity {
  const BreakSuggestionModel({
    required super.shouldBreak,
    required super.urgency,
    required super.suggestedDurationMinutes,
    required super.reason,
    required super.nearbySpots,
  });

  factory BreakSuggestionModel.fromJson(Map<String, dynamic> json) {
    final spots = json['nearbySpots'];
    return BreakSuggestionModel(
      shouldBreak: (json['shouldBreak'] as bool?) ?? false,
      urgency: (json['urgency'] as int?) ?? 0,
      suggestedDurationMinutes:
          (json['suggestedDurationMinutes'] as int?) ?? 15,
      reason: (json['reason'] as String?) ?? '',
      nearbySpots: spots is List
          ? spots.map((e) => e.toString()).toList()
          : <String>[],
    );
  }
}
