import '../../domain/entities/consent_entity.dart';

class ConsentModel extends ConsentEntity {
  const ConsentModel({
    required super.consentType,
    required super.isGranted,
    super.grantedAt,
    super.description,
  });

  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    return ConsentModel(
      consentType: json['consentType'] as String? ?? '',
      isGranted: json['isGranted'] as bool? ?? false,
      grantedAt: json['grantedAt'] != null
          ? DateTime.tryParse(json['grantedAt'] as String)
          : null,
      description: json['description'] as String?,
    );
  }
}

class DataRequestModel extends DataRequestEntity {
  const DataRequestModel({
    super.requestId,
    required super.requestType,
    required super.status,
    super.reason,
    super.downloadUrl,
    super.requestedAt,
    super.readyAt,
    super.expiresAt,
  });

  factory DataRequestModel.fromJson(Map<String, dynamic> json) {
    return DataRequestModel(
      requestId: json['requestId'] as String?,
      requestType: (json['requestType'] ?? 'export').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      reason: json['reason'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'] as String)
          : null,
      readyAt: json['readyAt'] != null
          ? DateTime.tryParse(json['readyAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }
}
