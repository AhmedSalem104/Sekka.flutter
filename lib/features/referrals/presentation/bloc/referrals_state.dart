import 'package:equatable/equatable.dart';

import '../../data/models/referral_model.dart';
import '../../data/models/referral_stats_model.dart';

sealed class ReferralsState extends Equatable {
  const ReferralsState();
  @override
  List<Object?> get props => [];
}

final class ReferralsInitial extends ReferralsState {
  const ReferralsInitial();
}

final class ReferralsLoading extends ReferralsState {
  const ReferralsLoading();
}

final class ReferralsLoaded extends ReferralsState {
  const ReferralsLoaded({
    required this.stats,
    required this.referrals,
    required this.code,
  });

  final ReferralStatsModel stats;
  final List<ReferralModel> referrals;
  final String code;

  @override
  List<Object?> get props => [stats, referrals, code];
}

final class ReferralsError extends ReferralsState {
  const ReferralsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
