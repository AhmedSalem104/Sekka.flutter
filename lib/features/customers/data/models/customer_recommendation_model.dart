class CustomerRecommendationModel {
  const CustomerRecommendationModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.priority,
    required this.isRead,
    required this.isDismissed,
    required this.isActedOn,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String type;
  final String? priority;
  final bool isRead;
  final bool isDismissed;
  final bool isActedOn;
  final DateTime? createdAt;

  factory CustomerRecommendationModel.fromJson(Map<String, dynamic> json) {
    return CustomerRecommendationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? '',
      priority: json['priority'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isDismissed: json['isDismissed'] as bool? ?? false,
      isActedOn: json['isActedOn'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
