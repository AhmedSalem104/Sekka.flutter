import 'package:equatable/equatable.dart';

class AppNoticeModel extends Equatable {
  const AppNoticeModel({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.actionUrl,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String message;
  final String? type;
  final String? actionUrl;
  final DateTime? expiresAt;

  factory AppNoticeModel.fromJson(Map<String, dynamic> json) {
    return AppNoticeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String?,
      actionUrl: json['actionUrl'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id];
}
