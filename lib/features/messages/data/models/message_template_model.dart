class MessageTemplateModel {
  const MessageTemplateModel({
    required this.id,
    required this.messageText,
    required this.category,
    required this.usageCount,
    required this.isSystemTemplate,
    required this.sortOrder,
  });

  final String id;
  final String messageText;
  final int category;
  final int usageCount;
  final bool isSystemTemplate;
  final int sortOrder;

  factory MessageTemplateModel.fromJson(Map<String, dynamic> json) {
    return MessageTemplateModel(
      id: json['id'] as String,
      messageText: json['messageText'] as String,
      category: json['category'] as int? ?? 4,
      usageCount: json['usageCount'] as int? ?? 0,
      isSystemTemplate: json['isSystemTemplate'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'messageText': messageText,
        'category': category,
      };

  Map<String, dynamic> toUpdateJson() => {
        'messageText': messageText,
        'category': category,
        'sortOrder': sortOrder,
      };
}
