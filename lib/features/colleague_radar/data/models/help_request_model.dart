import 'package:equatable/equatable.dart';

class HelpRequestModel extends Equatable {
  const HelpRequestModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.helpType,
    required this.status,
    this.responderId,
    this.responderName,
    required this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String driverId;
  final String driverName;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String helpType;
  final String status;
  final String? responderId;
  final String? responderName;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  bool get isPending => status == 'Pending';
  bool get isAccepted => status == 'Accepted';
  bool get isResolved => status == 'Resolved';

  factory HelpRequestModel.fromJson(Map<String, dynamic> json) {
    return HelpRequestModel(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      helpType: json['helpType'] as String? ?? 'Other',
      status: json['status'] as String? ?? 'Pending',
      responderId: json['responderId'] as String?,
      responderName: json['responderName'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, status, responderId, resolvedAt];
}
