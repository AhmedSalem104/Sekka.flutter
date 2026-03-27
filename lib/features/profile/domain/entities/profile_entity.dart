import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.profileImageUrl,
    required this.licenseImageUrl,
    required this.vehicleType,
    required this.isOnline,
    required this.defaultRegion,
    required this.cashOnHand,
    required this.walletBalance,
    required this.totalPoints,
    required this.level,
    required this.nextLevelPoints,
    required this.joinedAt,
    required this.totalOrders,
    required this.totalDelivered,
    required this.averageRating,
    required this.shiftStatus,
    required this.healthScore,
    required this.badgesCount,
    required this.currentStreak,
    required this.completionPercentage,
    required this.todayOrdersCount,
    required this.todayEarnings,
    required this.referralCode,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final String? licenseImageUrl;
  final int vehicleType;
  final bool isOnline;
  final String? defaultRegion;
  final double cashOnHand;
  final double walletBalance;
  final int totalPoints;
  final int level;
  final int nextLevelPoints;
  final DateTime joinedAt;
  final int totalOrders;
  final int totalDelivered;
  final double averageRating;
  final int shiftStatus;
  final int healthScore;
  final int badgesCount;
  final int currentStreak;
  final int completionPercentage;
  final int todayOrdersCount;
  final double todayEarnings;
  final String? referralCode;

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        profileImageUrl,
        licenseImageUrl,
        vehicleType,
        isOnline,
        defaultRegion,
        cashOnHand,
        walletBalance,
        totalPoints,
        level,
        nextLevelPoints,
        joinedAt,
        totalOrders,
        totalDelivered,
        averageRating,
        shiftStatus,
        healthScore,
        badgesCount,
        currentStreak,
        completionPercentage,
        todayOrdersCount,
        todayEarnings,
        referralCode,
      ];
}
