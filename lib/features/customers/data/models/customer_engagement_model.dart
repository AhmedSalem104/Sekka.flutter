class CustomerEngagementModel {
  const CustomerEngagementModel({
    required this.totalOrders,
    required this.engagementScore,
    required this.level,
    this.lastInteraction,
    required this.daysSinceLastOrder,
  });

  final int totalOrders;
  final int engagementScore;
  final String level;
  final DateTime? lastInteraction;
  final int daysSinceLastOrder;

  factory CustomerEngagementModel.fromJson(Map<String, dynamic> json) {
    return CustomerEngagementModel(
      totalOrders: json['totalOrders'] as int? ?? 0,
      engagementScore: json['engagementScore'] as int? ?? 0,
      level: json['level'] as String? ?? 'جديد',
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.tryParse(json['lastInteraction'] as String)
          : null,
      daysSinceLastOrder: json['daysSinceLastOrder'] as int? ?? -1,
    );
  }
}
