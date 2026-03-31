import 'package:equatable/equatable.dart';

import '../../data/models/badge_model.dart';
import '../../data/models/badge_verify_model.dart';

sealed class BadgeState extends Equatable {
  const BadgeState();

  @override
  List<Object?> get props => [];
}

final class BadgeInitial extends BadgeState {
  const BadgeInitial();
}

final class BadgeLoading extends BadgeState {
  const BadgeLoading();
}

final class BadgeLoaded extends BadgeState {
  const BadgeLoaded({required this.badge});
  final BadgeModel badge;

  @override
  List<Object?> get props => [badge];
}

final class BadgeError extends BadgeState {
  const BadgeError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

final class BadgeVerifying extends BadgeState {
  const BadgeVerifying({required this.badge});
  final BadgeModel badge;

  @override
  List<Object?> get props => [badge];
}

final class BadgeVerified extends BadgeState {
  const BadgeVerified({required this.badge, required this.result});
  final BadgeModel badge;
  final BadgeVerifyModel result;

  @override
  List<Object?> get props => [badge, result];
}

final class BadgeVerifyError extends BadgeState {
  const BadgeVerifyError({required this.badge, required this.message});
  final BadgeModel badge;
  final String message;

  @override
  List<Object?> get props => [badge, message];
}
