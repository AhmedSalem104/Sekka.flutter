class FavoriteDriverModel {
  const FavoriteDriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.linkedDriverId,
    required this.isAppUser,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? linkedDriverId;
  final bool isAppUser;
  final DateTime createdAt;

  factory FavoriteDriverModel.fromJson(Map<String, dynamic> json) {
    return FavoriteDriverModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      linkedDriverId: json['linkedDriverId'] as String?,
      isAppUser: json['isAppUser'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class DriverByPhoneModel {
  const DriverByPhoneModel({
    required this.id,
    required this.name,
    this.vehicleType,
    required this.isOnline,
    this.profileImageUrl,
  });

  final String id;
  final String name;
  final String? vehicleType;
  final bool isOnline;
  final String? profileImageUrl;

  factory DriverByPhoneModel.fromJson(Map<String, dynamic> json) {
    return DriverByPhoneModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      vehicleType: json['vehicleType'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

class ShareLinkModel {
  const ShareLinkModel({
    required this.shareToken,
    required this.shareUrl,
    required this.expiresAt,
    required this.messageTemplate,
  });

  final String shareToken;
  final String shareUrl;
  final DateTime expiresAt;
  final String messageTemplate;

  factory ShareLinkModel.fromJson(Map<String, dynamic> json) {
    return ShareLinkModel(
      shareToken: json['shareToken'] as String? ?? '',
      shareUrl: json['shareUrl'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      messageTemplate: json['messageTemplate'] as String? ?? '',
    );
  }
}
