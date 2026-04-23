import '../../../../shared/utils/safe_parse.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionType,
    this.actionData,
    required this.priority,
    required this.createdAt,
  });

  final String id;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final String? actionType;
  final String? actionData;
  final int priority;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      notificationType: json['notificationType'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      actionType: json['actionType'] as String?,
      actionData: json['actionData'] as String?,
      priority: safeInt(json['priority'], 1),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'notificationType': notificationType,
        'title': title,
        'message': message,
        'isRead': isRead,
        'actionType': actionType,
        'actionData': actionData,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        notificationType: notificationType,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        actionType: actionType,
        actionData: actionData,
        priority: priority,
        createdAt: createdAt,
      );
}
