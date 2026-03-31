import 'package:equatable/equatable.dart';

sealed class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

final class RouteOptimizeRequested extends RouteEvent {
  const RouteOptimizeRequested({
    this.orderIds,
    this.startLatitude,
    this.startLongitude,
    this.optimizationType,
  });

  final List<String>? orderIds;
  final double? startLatitude;
  final double? startLongitude;
  final String? optimizationType;

  @override
  List<Object?> get props => [orderIds, startLatitude, startLongitude, optimizationType];
}

final class RouteActiveLoadRequested extends RouteEvent {
  const RouteActiveLoadRequested();
}

final class RouteReorderRequested extends RouteEvent {
  const RouteReorderRequested({
    required this.routeId,
    required this.orderIds,
  });

  final String routeId;
  final List<String> orderIds;

  @override
  List<Object?> get props => [routeId, orderIds];
}

final class RouteAddOrderRequested extends RouteEvent {
  const RouteAddOrderRequested({
    required this.routeId,
    required this.orderId,
  });

  final String routeId;
  final String orderId;

  @override
  List<Object?> get props => [routeId, orderId];
}

final class RouteCompleteRequested extends RouteEvent {
  const RouteCompleteRequested({required this.routeId});

  final String routeId;

  @override
  List<Object?> get props => [routeId];
}

final class RouteClearMessage extends RouteEvent {
  const RouteClearMessage();
}
