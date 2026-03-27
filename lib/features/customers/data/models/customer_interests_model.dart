class PreferredPartnerEntry {
  const PreferredPartnerEntry({
    required this.partnerId,
    required this.partnerName,
    required this.orderCount,
  });

  final String partnerId;
  final String partnerName;
  final int orderCount;

  factory PreferredPartnerEntry.fromJson(Map<String, dynamic> json) {
    return PreferredPartnerEntry(
      partnerId: json['partnerId'] as String,
      partnerName: json['partnerName'] as String,
      orderCount: json['orderCount'] as int? ?? 0,
    );
  }
}

class CustomerInterestsModel {
  const CustomerInterestsModel({
    required this.topCategories,
    required this.preferredPartners,
    required this.preferredDeliveryTimes,
    required this.averageOrderValue,
  });

  final List<String> topCategories;
  final List<PreferredPartnerEntry> preferredPartners;
  final List<String> preferredDeliveryTimes;
  final double averageOrderValue;

  factory CustomerInterestsModel.fromJson(Map<String, dynamic> json) {
    return CustomerInterestsModel(
      topCategories: (json['topCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferredPartners: (json['preferredPartners'] as List<dynamic>?)
              ?.map((e) =>
                  PreferredPartnerEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      preferredDeliveryTimes:
          (json['preferredDeliveryTimes'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      averageOrderValue:
          (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
