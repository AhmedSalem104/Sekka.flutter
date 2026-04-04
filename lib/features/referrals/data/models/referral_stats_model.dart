class ReferralStatsModel {
  const ReferralStatsModel({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalEarnings,
    required this.pendingRewards,
  });

  final int totalReferrals;
  final int activeReferrals;
  final double totalEarnings;
  final double pendingRewards;

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      totalReferrals: json['totalReferrals'] as int? ?? 0,
      activeReferrals: json['activeReferrals'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      pendingRewards: (json['pendingRewards'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalReferrals': totalReferrals,
        'activeReferrals': activeReferrals,
        'totalEarnings': totalEarnings,
        'pendingRewards': pendingRewards,
      };
}
