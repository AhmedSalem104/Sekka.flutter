class SosModel {
  const SosModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.notifiedContacts,
    required this.adminNotified,
    this.notes,
    required this.activatedAt,
    this.resolvedAt,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String status;
  final List<String> notifiedContacts;
  final bool adminNotified;
  final String? notes;
  final DateTime activatedAt;
  final DateTime? resolvedAt;

  factory SosModel.fromJson(Map<String, dynamic> json) {
    return SosModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String,
      notifiedContacts: (json['notifiedContacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      adminNotified: json['adminNotified'] as bool? ?? false,
      notes: json['notes'] as String?,
      activatedAt: DateTime.parse(json['activatedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }
}
