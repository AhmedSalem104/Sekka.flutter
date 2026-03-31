class BreakSuggestionEntity {
  const BreakSuggestionEntity({
    required this.shouldBreak,
    required this.urgency,
    required this.suggestedDurationMinutes,
    required this.reason,
    required this.nearbySpots,
  });

  final bool shouldBreak;

  /// 0 = none, 1 = low, 2 = medium, 3 = high
  final int urgency;
  final int suggestedDurationMinutes;
  final String reason;
  final List<String> nearbySpots;
}
