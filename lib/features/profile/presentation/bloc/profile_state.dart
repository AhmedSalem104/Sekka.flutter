import 'package:equatable/equatable.dart';

import '../../domain/entities/health_score_entity.dart';
import '../../domain/entities/profile_completion_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_stats_entity.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    required this.completion,
    required this.stats,
    this.healthScore,
    this.isUpdating = false,
  });

  final ProfileEntity profile;
  final ProfileCompletionEntity completion;
  final ProfileStatsEntity stats;
  final HealthScoreEntity? healthScore;
  final bool isUpdating;

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    ProfileCompletionEntity? completion,
    ProfileStatsEntity? stats,
    HealthScoreEntity? healthScore,
    bool? isUpdating,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      completion: completion ?? this.completion,
      stats: stats ?? this.stats,
      healthScore: healthScore ?? this.healthScore,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [profile, completion, stats, healthScore, isUpdating];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
