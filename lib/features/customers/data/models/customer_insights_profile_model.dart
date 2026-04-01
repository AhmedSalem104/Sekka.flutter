class RfmScoreModel {
  const RfmScoreModel({
    required this.recencyScore,
    required this.frequencyScore,
    required this.monetaryScore,
    required this.totalScore,
    required this.segment,
  });

  final int recencyScore;
  final int frequencyScore;
  final int monetaryScore;
  final int totalScore;
  final String segment;

  factory RfmScoreModel.fromJson(Map<String, dynamic> json) {
    return RfmScoreModel(
      recencyScore: json['recencyScore'] as int? ?? 0,
      frequencyScore: json['frequencyScore'] as int? ?? 0,
      monetaryScore: json['monetaryScore'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      segment: json['segment'] as String? ?? 'New',
    );
  }
}

class CustomerInsightsProfileModel {
  const CustomerInsightsProfileModel({
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.engagementLevel,
    required this.lifetimeValue,
    required this.totalOrders,
    required this.topInterests,
    required this.currentSegments,
    this.behaviorSummary,
    this.lastOrderDate,
    this.daysSinceLastOrder,
    required this.rfmScore,
  });

  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String engagementLevel;
  final double lifetimeValue;
  final int totalOrders;
  final List<String> topInterests;
  final List<String> currentSegments;
  final String? behaviorSummary;
  final DateTime? lastOrderDate;
  final int? daysSinceLastOrder;
  final RfmScoreModel rfmScore;

  factory CustomerInsightsProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerInsightsProfileModel(
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      engagementLevel: json['engagementLevel'] as String? ?? 'Low',
      lifetimeValue: (json['lifetimeValue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      topInterests: (json['topInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      currentSegments: (json['currentSegments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      behaviorSummary: json['behaviorSummary'] as String?,
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.tryParse(json['lastOrderDate'] as String)
          : null,
      daysSinceLastOrder: json['daysSinceLastOrder'] as int?,
      rfmScore: json['rfmScore'] != null
          ? RfmScoreModel.fromJson(json['rfmScore'] as Map<String, dynamic>)
          : const RfmScoreModel(
              recencyScore: 0,
              frequencyScore: 0,
              monetaryScore: 0,
              totalScore: 0,
              segment: 'New',
            ),
    );
  }
}
