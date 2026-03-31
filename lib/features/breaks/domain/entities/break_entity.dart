class BreakEntity {
  const BreakEntity({
    required this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.locationDescription,
    required this.energyBefore,
    this.energyAfter,
  });

  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String locationDescription;
  final int energyBefore;
  final int? energyAfter;

  bool get isActive => endTime == null;
}
