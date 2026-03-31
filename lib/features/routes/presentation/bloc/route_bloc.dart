import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/route_repository.dart';
import 'route_event.dart';
import 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({required RouteRepository repository})
      : _repository = repository,
        super(const RouteInitial()) {
    on<RouteActiveLoadRequested>(_onLoadActive);
    on<RouteOptimizeRequested>(_onOptimize);
    on<RouteReorderRequested>(_onReorder);
    on<RouteAddOrderRequested>(_onAddOrder);
    on<RouteCompleteRequested>(_onComplete);
    on<RouteClearMessage>(_onClearMessage);
  }

  final RouteRepository _repository;

  Future<void> _onLoadActive(
    RouteActiveLoadRequested event,
    Emitter<RouteState> emit,
  ) async {
    emit(const RouteLoading());

    try {
      final route = await _repository.getActiveRoute();
      emit(RouteLoaded(activeRoute: route));
    } on ApiException {
      // مفيش مسار نشط — نعرض الـ empty state مش error
      emit(const RouteLoaded());
    } catch (_) {
      emit(const RouteLoaded());
    }
  }

  Future<void> _onOptimize(
    RouteOptimizeRequested event,
    Emitter<RouteState> emit,
  ) async {
    final current = state;
    final loaded = current is RouteLoaded
        ? current
        : const RouteLoaded();

    emit(loaded.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      final route = await _repository.optimizeRoute(
        orderIds: event.orderIds,
        startLatitude: event.startLatitude,
        startLongitude: event.startLongitude,
        optimizationType: event.optimizationType,
      );
      emit(loaded.copyWith(
        activeRoute: () => route,
        isActionInProgress: false,
        actionMessage: () => AppStrings.routeOptimized,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  Future<void> _onReorder(
    RouteReorderRequested event,
    Emitter<RouteState> emit,
  ) async {
    final current = state;
    if (current is! RouteLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      final route = await _repository.reorderRoute(
        event.routeId,
        event.orderIds,
      );
      emit(current.copyWith(
        activeRoute: () => route,
        isActionInProgress: false,
        actionMessage: () => AppStrings.routeReordered,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  Future<void> _onAddOrder(
    RouteAddOrderRequested event,
    Emitter<RouteState> emit,
  ) async {
    final current = state;
    if (current is! RouteLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      final route = await _repository.addOrderToRoute(
        event.routeId,
        event.orderId,
      );
      emit(current.copyWith(
        activeRoute: () => route,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderAddedToRoute,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  Future<void> _onComplete(
    RouteCompleteRequested event,
    Emitter<RouteState> emit,
  ) async {
    final current = state;
    if (current is! RouteLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      await _repository.completeRoute(event.routeId);
      emit(current.copyWith(
        activeRoute: () => null,
        isActionInProgress: false,
        actionMessage: () => AppStrings.routeCompleted,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  void _onClearMessage(
    RouteClearMessage event,
    Emitter<RouteState> emit,
  ) {
    final current = state;
    if (current is RouteLoaded) {
      emit(current.copyWith(
        actionMessage: () => null,
        isActionError: false,
      ));
    }
  }
}
