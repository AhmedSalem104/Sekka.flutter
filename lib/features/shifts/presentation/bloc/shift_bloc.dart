import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/entities/shift_entity.dart';
import '../../domain/entities/shift_summary_entity.dart';
import '../../domain/repositories/shift_repository.dart';
import 'shift_event.dart';
import 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  ShiftBloc({required ShiftRepository repository})
      : _repository = repository,
        super(const ShiftInitial()) {
    on<ShiftCheckRequested>(_onCheck);
    on<ShiftStartRequested>(_onStart);
    on<ShiftEndRequested>(_onEnd);
    on<ShiftSummaryRequested>(_onSummary);
  }

  final ShiftRepository _repository;

  Future<void> _onCheck(
    ShiftCheckRequested event,
    Emitter<ShiftState> emit,
  ) async {
    final prev = state;
    if (prev is! ShiftLoaded) {
      emit(const ShiftLoading());
    }
    try {
      // Fetch separately to avoid ParallelWaitError killing both
      ShiftEntity? current;
      ShiftSummaryEntity? summary;

      try {
        current = await _repository.getCurrentShift();
      } catch (_) {
        // No active shift or network error — treat as null
      }

      try {
        summary = await _repository.getSummary();
      } catch (_) {
        // Keep old summary if fetch fails
        summary = prev is ShiftLoaded ? prev.summary : null;
      }

      emit(ShiftLoaded(currentShift: current, summary: summary));
    } catch (_) {
      if (prev is! ShiftLoaded) emit(ShiftError(AppStrings.unknownError));
    }
  }

  Future<Position> _getPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      return Position(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  Future<void> _onStart(
    ShiftStartRequested event,
    Emitter<ShiftState> emit,
  ) async {
    final prev = state;
    if (prev is ShiftLoaded) {
      emit(prev.copyWith(isToggling: true));
    }
    try {
      final position = await _getPosition();
      final shift = await _repository.startShift(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      ShiftSummaryEntity? summary;
      try {
        summary = await _repository.getSummary();
      } catch (_) {
        summary = prev is ShiftLoaded ? prev.summary : null;
      }

      emit(ShiftLoaded(currentShift: shift, summary: summary));
    } on ApiException catch (e) {
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
      emit(ShiftError(e.message));
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
    } catch (_) {
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
      emit(ShiftError(AppStrings.unknownError));
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
    }
  }

  Future<void> _onEnd(
    ShiftEndRequested event,
    Emitter<ShiftState> emit,
  ) async {
    final prev = state;
    if (prev is ShiftLoaded) {
      emit(prev.copyWith(isToggling: true));
    }
    try {
      await _repository.endShift();

      ShiftSummaryEntity? summary;
      try {
        summary = await _repository.getSummary();
      } catch (_) {
        summary = prev is ShiftLoaded ? prev.summary : null;
      }

      emit(ShiftLoaded(summary: summary));
    } on ApiException catch (e) {
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
      emit(ShiftError(e.message));
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
    } catch (_) {
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
      emit(ShiftError(AppStrings.unknownError));
      if (prev is ShiftLoaded) emit(prev.copyWith(isToggling: false));
    }
  }

  Future<void> _onSummary(
    ShiftSummaryRequested event,
    Emitter<ShiftState> emit,
  ) async {
    try {
      ShiftEntity? current;
      try {
        current = await _repository.getCurrentShift();
      } catch (_) {}

      final summary = await _repository.getSummary();
      emit(ShiftLoaded(currentShift: current, summary: summary));
    } on ApiException catch (e) {
      emit(ShiftError(e.message));
    } catch (_) {
      emit(ShiftError(AppStrings.unknownError));
    }
  }
}
