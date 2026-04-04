import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../data/repositories/gamification_repository.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  GamificationBloc({required this.repository})
      : super(const GamificationInitial()) {
    on<GamificationLoadRequested>(_onLoad);
    on<GamificationLeaderboardRequested>(_onLeaderboard);
    on<GamificationClaimRequested>(_onClaim);
    on<GamificationPointsHistoryRequested>(_onPointsHistory);
  }

  final GamificationRepository repository;

  Future<void> _onLoad(
    GamificationLoadRequested event,
    Emitter<GamificationState> emit,
  ) async {
    emit(const GamificationLoading());

    final results = await (
      repository.getChallenges(),
      repository.getAchievements(),
      repository.getPointsTotal(),
      repository.getLevel(),
    ).wait;

    final (challenges, achievements, points, level) = results;

    switch ((challenges, achievements, points, level)) {
      case (
          ApiSuccess(data: final c),
          ApiSuccess(data: final a),
          ApiSuccess(data: final p),
          ApiSuccess(data: final l),
        ):
        emit(GamificationLoaded(
          challenges: c,
          achievements: a,
          totalPoints: p,
          level: l,
        ));
      case (ApiFailure(:final error), _, _, _):
        emit(GamificationError(message: error.arabicMessage));
      case (_, ApiFailure(:final error), _, _):
        emit(GamificationError(message: error.arabicMessage));
      case (_, _, ApiFailure(:final error), _):
        emit(GamificationError(message: error.arabicMessage));
      case (_, _, _, ApiFailure(:final error)):
        emit(GamificationError(message: error.arabicMessage));
    }
  }

  Future<void> _onLeaderboard(
    GamificationLeaderboardRequested event,
    Emitter<GamificationState> emit,
  ) async {
    final current = state;
    if (current is! GamificationLoaded) return;

    emit(current.copyWith(isLoadingLeaderboard: true));

    final result = await repository.getLeaderboard(period: event.period);
    switch (result) {
      case ApiSuccess(:final data):
        emit(current.copyWith(
          leaderboard: data,
          isLoadingLeaderboard: false,
        ));
      case ApiFailure(:final error):
        emit(current.copyWith(isLoadingLeaderboard: false));
        addError(error.arabicMessage);
    }
  }

  Future<void> _onClaim(
    GamificationClaimRequested event,
    Emitter<GamificationState> emit,
  ) async {
    final current = state;
    if (current is! GamificationLoaded) return;

    emit(current.copyWith(isClaimingId: event.challengeId));

    final result = await repository.claimChallenge(event.challengeId);
    switch (result) {
      case ApiSuccess():
        // Reload all data after claiming
        add(const GamificationLoadRequested());
      case ApiFailure(:final error):
        emit(current.copyWith());
        addError(error.arabicMessage);
    }
  }

  Future<void> _onPointsHistory(
    GamificationPointsHistoryRequested event,
    Emitter<GamificationState> emit,
  ) async {
    final current = state;
    if (current is! GamificationLoaded) return;

    emit(current.copyWith(isLoadingHistory: true));

    final result = await repository.getPointsHistory(page: event.page);
    switch (result) {
      case ApiSuccess(:final data):
        final allHistory = event.page == 1
            ? data.items
            : [...current.pointsHistory, ...data.items];
        emit(current.copyWith(
          pointsHistory: allHistory,
          pointsHistoryPage: event.page,
          hasMoreHistory: data.hasNextPage,
          isLoadingHistory: false,
        ));
      case ApiFailure(:final error):
        emit(current.copyWith(isLoadingHistory: false));
        addError(error.arabicMessage);
    }
  }
}
