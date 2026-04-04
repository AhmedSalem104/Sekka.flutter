import 'package:equatable/equatable.dart';

class PointHistoryModel extends Equatable {
  const PointHistoryModel({
    required this.id,
    required this.points,
    required this.reason,
    required this.referenceType,
    required this.referenceId,
    required this.createdAt,
  });

  final String id;
  final int points;
  final String reason;
  final String referenceType;
  final String referenceId;
  final DateTime createdAt;

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    return PointHistoryModel(
      id: json['id'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      referenceType: json['referenceType'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        points,
        reason,
        referenceType,
        referenceId,
        createdAt,
      ];
}
