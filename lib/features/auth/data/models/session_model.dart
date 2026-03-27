import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.deviceName,
    required super.devicePlatform,
    super.ipAddress,
    required super.lastActiveAt,
    required super.isCurrentSession,
    required super.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String? ?? '',
      devicePlatform: json['devicePlatform'] as int? ?? 0,
      ipAddress: json['ipAddress'] as String?,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      isCurrentSession: json['isCurrentSession'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
