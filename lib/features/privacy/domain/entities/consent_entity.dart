import 'package:equatable/equatable.dart';

class ConsentEntity extends Equatable {
  const ConsentEntity({
    required this.consentType,
    required this.isGranted,
    this.grantedAt,
    this.description,
  });

  final String consentType;
  final bool isGranted;
  final DateTime? grantedAt;
  final String? description;

  ConsentEntity copyWith({bool? isGranted, DateTime? grantedAt}) {
    return ConsentEntity(
      consentType: consentType,
      isGranted: isGranted ?? this.isGranted,
      grantedAt: grantedAt ?? this.grantedAt,
      description: description,
    );
  }

  @override
  List<Object?> get props => [consentType, isGranted, grantedAt, description];
}

class DataRequestEntity extends Equatable {
  const DataRequestEntity({
    this.requestId,
    required this.requestType,
    required this.status,
    this.reason,
    this.downloadUrl,
    this.requestedAt,
    this.readyAt,
    this.expiresAt,
  });

  final String? requestId;
  final String requestType;
  final String status;
  final String? reason;
  final String? downloadUrl;
  final DateTime? requestedAt;
  final DateTime? readyAt;
  final DateTime? expiresAt;

  bool get isPending => status == 'Pending' || status == '0';
  bool get isReady => status == 'Ready' || status == '1';

  @override
  List<Object?> get props => [
        requestId,
        requestType,
        status,
        reason,
        downloadUrl,
        requestedAt,
      ];
}
