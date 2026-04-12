import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../data/models/help_request_model.dart';
import '../../data/models/nearby_driver_model.dart';
import '../../data/repositories/colleague_radar_repository.dart';
import 'colleague_radar_event.dart';
import 'colleague_radar_state.dart';

class ColleagueRadarBloc
    extends Bloc<ColleagueRadarEvent, ColleagueRadarState> {
  ColleagueRadarBloc({required this.repository})
      : super(const ColleagueRadarInitial()) {
    on<ColleagueRadarLoadRequested>(_onLoad);
    on<ColleagueRadarCreateHelpRequest>(_onCreate);
    on<ColleagueRadarRespondRequested>(_onRespond);
    on<ColleagueRadarResolveRequested>(_onResolve);
    on<ColleagueRadarUpdateLocation>(_onUpdateLocation);
  }

  final ColleagueRadarRepository repository;

  double _lastLat = 0;
  double _lastLng = 0;

  Future<void> _onLoad(
    ColleagueRadarLoadRequested event,
    Emitter<ColleagueRadarState> emit,
  ) async {
    _lastLat = event.latitude;
    _lastLng = event.longitude;

    if (state is! ColleagueRadarLoaded) {
      emit(const ColleagueRadarLoading());
    }

    final results = await (
      repository.getNearbyDrivers(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
      repository.getNearbyHelpRequests(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
      repository.getMyHelpRequests(),
    ).wait;

    final (drivers, requests, myRequests) = results;

    // myRequests is the most important — always show even if nearby fails
    final myData = switch (myRequests) {
      ApiSuccess(data: final m) => m,
      _ => <HelpRequestModel>[],
    };
    final driversData = switch (drivers) {
      ApiSuccess(data: final d) => d,
      _ => <NearbyDriverModel>[],
    };
    final requestsData = switch (requests) {
      ApiSuccess(data: final r) => r,
      _ => <HelpRequestModel>[],
    };

    // Only show error if ALL three failed
    if (myData.isEmpty &&
        driversData.isEmpty &&
        requestsData.isEmpty &&
        myRequests is ApiFailure) {
      emit(ColleagueRadarError(
        message: (myRequests as ApiFailure).error.arabicMessage,
      ));
      return;
    }

    emit(ColleagueRadarLoaded(
      nearbyDrivers: driversData,
      nearbyRequests: requestsData,
      myRequests: myData,
    ));
  }

  Future<void> _onCreate(
    ColleagueRadarCreateHelpRequest event,
    Emitter<ColleagueRadarState> emit,
  ) async {
    final current = state;
    if (current is! ColleagueRadarLoaded) return;

    emit(current.copyWith(isSubmitting: true));

    final result = await repository.createHelpRequest(
      title: event.title,
      description: event.description,
      latitude: event.latitude,
      longitude: event.longitude,
      helpType: event.helpType,
    );

    switch (result) {
      case ApiSuccess():
        add(ColleagueRadarLoadRequested(
          latitude: _lastLat,
          longitude: _lastLng,
        ));
      case ApiFailure(:final error):
        emit(current.copyWith(
          isSubmitting: false,
          actionMessage: error.arabicMessage,
        ));
    }
  }

  Future<void> _onRespond(
    ColleagueRadarRespondRequested event,
    Emitter<ColleagueRadarState> emit,
  ) async {
    final current = state;
    if (current is! ColleagueRadarLoaded) return;

    emit(current.copyWith(isSubmitting: true));

    final result = await repository.respondToRequest(event.requestId);
    switch (result) {
      case ApiSuccess():
        add(ColleagueRadarLoadRequested(
          latitude: _lastLat,
          longitude: _lastLng,
        ));
      case ApiFailure(:final error):
        emit(current.copyWith(
          isSubmitting: false,
          actionMessage: error.arabicMessage,
        ));
    }
  }

  Future<void> _onUpdateLocation(
    ColleagueRadarUpdateLocation event,
    Emitter<ColleagueRadarState> emit,
  ) async {
    // Fire and forget — don't block event queue
    repository.updateLocation(
      latitude: event.latitude,
      longitude: event.longitude,
    );
  }

  Future<void> _onResolve(
    ColleagueRadarResolveRequested event,
    Emitter<ColleagueRadarState> emit,
  ) async {
    final current = state;
    if (current is! ColleagueRadarLoaded) return;

    emit(current.copyWith(isSubmitting: true));

    final result = await repository.resolveRequest(event.requestId);
    switch (result) {
      case ApiSuccess():
        add(ColleagueRadarLoadRequested(
          latitude: _lastLat,
          longitude: _lastLng,
        ));
      case ApiFailure(:final error):
        emit(current.copyWith(
          isSubmitting: false,
          actionMessage: error.arabicMessage,
        ));
    }
  }
}
