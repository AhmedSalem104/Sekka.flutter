class PickupPointModel {
  const PickupPointModel({
    required this.id,
    this.partnerId,
    this.partnerName,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    required this.averageWaitingMinutes,
    required this.driverRating,
    required this.visitCount,
  });

  final String id;
  final String? partnerId;
  final String? partnerName;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final double averageWaitingMinutes;
  final double driverRating;
  final int visitCount;

  factory PickupPointModel.fromJson(Map<String, dynamic> json) {
    return PickupPointModel(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String?,
      partnerName: json['partnerName'] as String?,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      averageWaitingMinutes:
          (json['averageWaitingMinutes'] as num?)?.toDouble() ?? 0.0,
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      visitCount: json['visitCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (partnerId != null) 'partnerId': partnerId,
    };
  }
}
