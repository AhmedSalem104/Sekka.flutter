class AddressModel {
  const AddressModel({
    required this.id,
    required this.addressText,
    this.latitude,
    this.longitude,
    required this.addressType,
    required this.visitCount,
    this.landmarks,
    this.deliveryNotes,
    this.distanceKm,
  });

  final String id;
  final String addressText;
  final double? latitude;
  final double? longitude;
  final int addressType;
  final int visitCount;
  final String? landmarks;
  final String? deliveryNotes;
  final double? distanceKm;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      addressText: json['addressText'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      addressType: json['addressType'] as int? ?? 0,
      visitCount: json['visitCount'] as int? ?? 0,
      landmarks: json['landmarks'] as String?,
      deliveryNotes: json['deliveryNotes'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'addressText': addressText,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'addressType': addressType,
        if (landmarks != null) 'landmarks': landmarks,
        if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
      };
}
