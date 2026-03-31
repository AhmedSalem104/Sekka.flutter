import 'package:equatable/equatable.dart';

import '../../data/models/route_model.dart';

sealed class RouteState extends Equatable {
  const RouteState();

  @override
  List<Object?> get props => [];
}

final class RouteInitial extends RouteState {
  const RouteInitial();
}

final class RouteLoading extends RouteState {
  const RouteLoading();
}

final class RouteLoaded extends RouteState {
  const RouteLoaded({
    this.activeRoute,
    this.isActionInProgress = false,
    this.actionMessage,
    this.isActionError = false,
  });

  final RouteModel? activeRoute;
  final bool isActionInProgress;
  final String? actionMessage;
  final bool isActionError;

  RouteLoaded copyWith({
    RouteModel? Function()? activeRoute,
    bool? isActionInProgress,
    String? Function()? actionMessage,
    bool? isActionError,
  }) {
    return RouteLoaded(
      activeRoute:
          activeRoute != null ? activeRoute() : this.activeRoute,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionMessage:
          actionMessage != null ? actionMessage() : this.actionMessage,
      isActionError: isActionError ?? this.isActionError,
    );
  }

  @override
  List<Object?> get props => [
        activeRoute,
        isActionInProgress,
        actionMessage,
        isActionError,
      ];
}

final class RouteError extends RouteState {
  const RouteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
