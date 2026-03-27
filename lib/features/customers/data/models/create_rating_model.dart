class CreateRatingModel {
  const CreateRatingModel({
    this.orderId,
    required this.ratingValue,
    this.quickResponse = false,
    this.clearAddress = false,
    this.respectfulBehavior = false,
    this.easyPayment = false,
    this.wrongAddress = false,
    this.noAnswer = false,
    this.delayedPickup = false,
    this.paymentIssue = false,
    this.feedbackText,
  });

  final String? orderId;
  final int ratingValue;
  final bool quickResponse;
  final bool clearAddress;
  final bool respectfulBehavior;
  final bool easyPayment;
  final bool wrongAddress;
  final bool noAnswer;
  final bool delayedPickup;
  final bool paymentIssue;
  final String? feedbackText;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'ratingValue': ratingValue,
      'quickResponse': quickResponse,
      'clearAddress': clearAddress,
      'respectfulBehavior': respectfulBehavior,
      'easyPayment': easyPayment,
      'wrongAddress': wrongAddress,
      'noAnswer': noAnswer,
      'delayedPickup': delayedPickup,
      'paymentIssue': paymentIssue,
    };

    if (orderId != null) {
      json['orderId'] = orderId;
    }

    if (feedbackText != null) {
      json['feedbackText'] = feedbackText;
    }

    return json;
  }
}
