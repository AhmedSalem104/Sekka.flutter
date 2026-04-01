import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/parking_repository.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  ParkingBloc({required ParkingRepository repository})
      : _repository = repository,
        super(const ParkingInitial()) {
    on<ParkingLoadRequested>(_onLoad);
    on<ParkingNearbyRequested>(_onNearby);
    on<ParkingCreateRequested>(_onCreate);
    on<ParkingDeleteRequested>(_onDelete);
    on<ParkingClearMessage>(_onClearMessage);
  }

  final ParkingRepository _repository;

  Future<void> _onLoad(
    ParkingLoadRequested event,
    Emitter<ParkingState> emit,
  ) async {
    emit(const ParkingLoading());
    try {
      final spots = await _repository.getAll();
      emit(ParkingLoaded(spots: spots));
    } on ApiException catch (e) {
      emit(ParkingError(e.message));
    } catch (_) {
      emit(ParkingError(AppStrings.unknownError));
    }
  }

  Future<void> _onNearby(
    ParkingNearbyRequested event,
    Emitter<ParkingState> emit,
  ) async {
    final current = state;
    final loaded =
        current is ParkingLoaded ? current : const ParkingLoaded();

    emit(loaded.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      final nearby = await _repository.getNearby(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      // Also load saved spots
      final spots = await _repository.getAll();
      emit(loaded.copyWith(
        spots: spots,
        nearbySpots: nearby,
        isActionInProgress: false,
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

  Future<void> _onCreate(
    ParkingCreateRequested event,
    Emitter<ParkingState> emit,
  ) async {
    final current = state;
    if (current is! ParkingLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      final newSpot = await _repository.create(
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
        qualityRating: event.qualityRating,
        isPaid: event.isPaid,
      );
      emit(current.copyWith(
        spots: [...current.spots, newSpot],
        isActionInProgress: false,
        actionMessage: () => AppStrings.parkingSaved,
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

  Future<void> _onDelete(
    ParkingDeleteRequested event,
    Emitter<ParkingState> emit,
  ) async {
    final current = state;
    if (current is! ParkingLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      await _repository.delete(event.id);
      emit(current.copyWith(
        spots: current.spots.where((s) => s.id != event.id).toList(),
        nearbySpots:
            current.nearbySpots.where((s) => s.id != event.id).toList(),
        isActionInProgress: false,
        actionMessage: () => AppStrings.parkingDeleted,
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
    ParkingClearMessage event,
    Emitter<ParkingState> emit,
  ) {
    final current = state;
    if (current is ParkingLoaded) {
      emit(current.copyWith(
        actionMessage: () => null,
        isActionError: false,
      ));
    }
  }
}
