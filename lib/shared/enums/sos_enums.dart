// SOS-related enums matching the API specification.

enum SosStatus {
  active(0, 'نشط'),
  resolved(1, 'تم الحل'),
  dismissed(2, 'ملغي'),
  expired(3, 'منتهي');

  const SosStatus(this.value, this.arabic);
  final int value;
  final String arabic;

  static SosStatus fromValue(int value) =>
      SosStatus.values.firstWhere((e) => e.value == value, orElse: () => active);

  static SosStatus fromString(String status) => switch (status.toLowerCase()) {
        'active' => active,
        'resolved' => resolved,
        'dismissed' => dismissed,
        'expired' => expired,
        _ => active,
      };

  bool get isActive => this == active;
  bool get isTerminal => this == resolved || this == dismissed || this == expired;
}

enum SosProblemType {
  accident(0, 'حادث سير'),
  vehicleBreakdown(1, 'عطل في المركبة'),
  theft(2, 'سرقة'),
  assault(3, 'اعتداء'),
  healthEmergency(4, 'حالة صحية طارئة'),
  roadBlock(5, 'طريق مغلق'),
  other(6, 'أخرى');

  const SosProblemType(this.value, this.arabic);
  final int value;
  final String arabic;

  static SosProblemType fromValue(int value) =>
      SosProblemType.values.firstWhere((e) => e.value == value, orElse: () => other);
}
