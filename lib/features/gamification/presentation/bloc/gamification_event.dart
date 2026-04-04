import 'package:equatable/equatable.dart';

sealed class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

final class GamificationLoadRequested extends GamificationEvent {
  const GamificationLoadRequested();
}

final class GamificationLeaderboardRequested extends GamificationEvent {
  const GamificationLeaderboardRequested({this.period = 'monthly'});
  final String period;

  @override
  List<Object?> get props => [period];
}

final class GamificationClaimRequested extends GamificationEvent {
  const GamificationClaimRequested({required this.challengeId});
  final String challengeId;

  @override
  List<Object?> get props => [challengeId];
}

final class GamificationPointsHistoryRequested extends GamificationEvent {
  const GamificationPointsHistoryRequested({this.page = 1});
  final int page;

  @override
  List<Object?> get props => [page];
}
