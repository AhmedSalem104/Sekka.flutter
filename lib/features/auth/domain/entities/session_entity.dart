import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  const SessionEntity({
    required this.id,
    required this.deviceName,
    required this.devicePlatform,
    this.ipAddress,
    required this.lastActiveAt,
    required this.isCurrentSession,
    required this.createdAt,
  });

  final String id;
  final String deviceName;
  final int devicePlatform;
  final String? ipAddress;
  final DateTime lastActiveAt;
  final bool isCurrentSession;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        deviceName,
        devicePlatform,
        ipAddress,
        lastActiveAt,
        isCurrentSession,
        createdAt,
      ];
}
