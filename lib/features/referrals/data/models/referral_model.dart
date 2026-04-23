import '../../../../shared/utils/safe_parse.dart';

class ReferralModel {
  const ReferralModel({
    required this.id,
    required this.referredDriverName,
    this.referredDriverPhone,
    required this.status,
    required this.rewardAmount,
    required this.createdAt,
    this.activatedAt,
  });

  final String id;
  final String referredDriverName;
  final String? referredDriverPhone;
  final int status; // 0=pending, 1=active, 2=expired
  final double rewardAmount;
  final DateTime createdAt;
  final DateTime? activatedAt;

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String? ?? '',
      referredDriverName: json['referredDriverName'] as String? ??
          json['name'] as String? ??
          '',
      referredDriverPhone: json['referredDriverPhone'] as String? ??
          json['phone'] as String?,
      status: parseReferralStatus(json['status']),
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      activatedAt: json['activatedAt'] != null
          ? DateTime.parse(json['activatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'referredDriverName': referredDriverName,
        'referredDriverPhone': referredDriverPhone,
        'status': status,
        'rewardAmount': rewardAmount,
        'createdAt': createdAt.toIso8601String(),
        'activatedAt': activatedAt?.toIso8601String(),
      };
}
