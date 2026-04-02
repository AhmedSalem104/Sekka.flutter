class CustomerBehaviorModel {
  const CustomerBehaviorModel({
    this.preferredOrderTime,
    this.preferredDayOfWeek,
    required this.averageOrderValue,
    required this.orderFrequencyPerMonth,
    this.preferredPaymentMethod,
    required this.preferredAreas,
    required this.spendingTier,
    required this.patterns,
  });

  final String? preferredOrderTime;
  final String? preferredDayOfWeek;
  final double averageOrderValue;
  final int orderFrequencyPerMonth;
  final String? preferredPaymentMethod;
  final List<String> preferredAreas;
  final String spendingTier;
  final List<String> patterns;

  factory CustomerBehaviorModel.fromJson(Map<String, dynamic> json) {
    return CustomerBehaviorModel(
      preferredOrderTime: json['preferredOrderTime'] as String?,
      preferredDayOfWeek: json['preferredDayOfWeek'] as String?,
      averageOrderValue:
          (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      orderFrequencyPerMonth: json['orderFrequencyPerMonth'] as int? ?? 0,
      preferredPaymentMethod: json['preferredPaymentMethod'] as String?,
      preferredAreas: (json['preferredAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      spendingTier: json['spendingTier'] as String? ?? 'Low',
      patterns: (json['patterns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
