class VerificationDocument {
  const VerificationDocument({
    required this.documentUrl,
    this.documentType,
    required this.uploadedAt,
  });

  final String documentUrl;
  final String? documentType;
  final DateTime uploadedAt;

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      documentUrl: json['documentUrl'] as String? ?? '',
      documentType: json['documentType'] as String?,
      uploadedAt: DateTime.parse(
        json['uploadedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class VerificationStatusModel {
  const VerificationStatusModel({
    required this.verificationStatus,
    required this.verificationStatusName,
    this.verifiedAt,
    this.rejectionReason,
    required this.requestedDocuments,
    required this.submittedDocuments,
  });

  final int verificationStatus;
  final String verificationStatusName;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final List<String> requestedDocuments;
  final List<VerificationDocument> submittedDocuments;

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VerificationStatusModel(
      verificationStatus: json['verificationStatus'] as int? ?? 0,
      verificationStatusName:
          json['verificationStatusName'] as String? ?? '',
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      requestedDocuments: (json['requestedDocuments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      submittedDocuments: (json['submittedDocuments'] as List<dynamic>?)
              ?.map(
                (e) => VerificationDocument.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
