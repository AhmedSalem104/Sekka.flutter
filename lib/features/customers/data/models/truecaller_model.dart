class TruecallerModel {
  const TruecallerModel({
    required this.phoneNumber,
    this.truecallerName,
    required this.spamScore,
    required this.isSpam,
  });

  final String phoneNumber;
  final String? truecallerName;
  final int spamScore;
  final bool isSpam;

  factory TruecallerModel.fromJson(Map<String, dynamic> json) {
    return TruecallerModel(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      truecallerName: json['truecallerName'] as String?,
      spamScore: json['spamScore'] as int? ?? 0,
      isSpam: json['isSpam'] as bool? ?? false,
    );
  }
}
