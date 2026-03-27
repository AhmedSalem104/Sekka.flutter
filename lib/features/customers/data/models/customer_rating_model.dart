class CustomerRatingModel {
  const CustomerRatingModel({
    required this.ratingValue,
    this.feedbackText,
    required this.createdAt,
    this.driverName,
  });

  final int ratingValue;
  final String? feedbackText;
  final DateTime createdAt;
  final String? driverName;

  factory CustomerRatingModel.fromJson(Map<String, dynamic> json) {
    return CustomerRatingModel(
      ratingValue: json['ratingValue'] as int? ?? 0,
      feedbackText: json['feedbackText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      driverName: json['driverName'] as String?,
    );
  }
}
