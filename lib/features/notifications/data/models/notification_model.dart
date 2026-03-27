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
      priority: json['priority'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
