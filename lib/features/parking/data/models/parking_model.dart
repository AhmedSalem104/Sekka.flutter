class ParkingModel {
  const ParkingModel({
    required this.id,
    this.latitude = 0,
    this.longitude = 0,
    this.address,
    this.qualityRating = 3,
    this.isPaid = false,
    this.usageCount = 0,
    this.lastUsedAt,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: json['id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String?,
      qualityRating: json['qualityRating'] as int? ?? 3,
      isPaid: json['isPaid'] as bool? ?? false,
      usageCount: json['usageCount'] as int? ?? 0,
      lastUsedAt: json['lastUsedAt'] as String?,
    );
  }

  final String id;
  final double latitude;
  final double longitude;
  final String? address;
  final int qualityRating;
  final bool isPaid;
  final int usageCount;
  final String? lastUsedAt;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        'qualityRating': qualityRating,
        'isPaid': isPaid,
      };
}
