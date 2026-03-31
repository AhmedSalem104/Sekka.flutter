import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/badge_repository.dart';
import '../../../../shared/network/api_result.dart';
import 'badge_event.dart';
import 'badge_state.dart';

class BadgeBloc extends Bloc<BadgeEvent, BadgeState> {
  BadgeBloc({required this.repository}) : super(const BadgeInitial()) {
    on<BadgeLoadRequested>(_onLoad);
    on<BadgeVerifyRequested>(_onVerify);
  }

  final BadgeRepository repository;

  Future<void> _onLoad(
    BadgeLoadRequested event,
    Emitter<BadgeState> emit,
  ) async {
    emit(const BadgeLoading());
    final result = await repository.getBadge();
    switch (result) {
      case ApiSuccess(:final data):
        emit(BadgeLoaded(badge: data));
      case ApiFailure(:final error):
        emit(BadgeError(message: error.message));
    }
  }

  Future<void> _onVerify(
    BadgeVerifyRequested event,
    Emitter<BadgeState> emit,
  ) async {
    final badge = switch (state) {
      BadgeLoaded(:final badge) => badge,
      BadgeVerified(:final badge) => badge,
      BadgeVerifyError(:final badge) => badge,
      _ => null,
    };
    if (badge == null) return;

    emit(BadgeVerifying(badge: badge));
    final result = await repository.verifyBadge(event.qrToken);
    switch (result) {
      case ApiSuccess(:final data):
        emit(BadgeVerified(badge: badge, result: data));
      case ApiFailure(:final error):
        emit(BadgeVerifyError(badge: badge, message: error.message));
    }
  }
}
