import 'package:equatable/equatable.dart';

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
    this.isUpdating = false,
  });

  final ProfileEntity profile;
  final ProfileCompletionEntity completion;
  final ProfileStatsEntity stats;
  final bool isUpdating;

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    ProfileCompletionEntity? completion,
    ProfileStatsEntity? stats,
    bool? isUpdating,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      completion: completion ?? this.completion,
      stats: stats ?? this.stats,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [profile, completion, stats, isUpdating];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
