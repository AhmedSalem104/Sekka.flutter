import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/entities/consent_entity.dart';
import '../../domain/repositories/privacy_repository.dart';
import 'privacy_event.dart';
import 'privacy_state.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  PrivacyBloc({required PrivacyRepository repository})
      : _repository = repository,
        super(const PrivacyInitial()) {
    on<PrivacyLoadRequested>(_onLoad);
    on<PrivacyConsentToggled>(_onConsentToggled);
    on<PrivacyExportRequested>(_onExportRequested);
    on<PrivacyDeleteRequested>(_onDeleteRequested);
    on<PrivacyErrorCleared>(_onErrorCleared);
  }

  final PrivacyRepository _repository;

  Future<void> _onLoad(
    PrivacyLoadRequested event,
    Emitter<PrivacyState> emit,
  ) async {
    final current = state;
    if (current is! PrivacyLoaded) {
      emit(const PrivacyLoading());
    }
    try {
      final consents = await _repository.getConsents();
      DataRequestEntity? deleteStatus;
      try {
        deleteStatus = await _repository.getDeleteStatus();
      } catch (_) {
        // Non-critical — ignore if no delete request exists
      }
      emit(PrivacyLoaded(consents: consents, deleteStatus: deleteStatus));
    } on ApiException catch (e) {
      if (current is! PrivacyLoaded) emit(PrivacyError(e.message));
    } catch (_) {
      if (current is! PrivacyLoaded) {
        emit(PrivacyError(AppStrings.unknownError));
      }
    }
  }

  Future<void> _onConsentToggled(
    PrivacyConsentToggled event,
    Emitter<PrivacyState> emit,
  ) async {
    final current = state;
    if (current is! PrivacyLoaded) return;

    // Optimistic update
    final optimisticConsents = current.consents.map((c) {
      if (c.consentType == event.consentType) {
        return c.copyWith(isGranted: event.isGranted);
      }
      return c;
    }).toList();
    emit(current.copyWith(consents: optimisticConsents, isSaving: true));

    try {
      await _repository.updateConsent(event.consentType, event.isGranted);
      emit(current.copyWith(consents: optimisticConsents, isSaving: false));
    } on ApiException catch (e) {
      // Revert
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(
        isSaving: false,
        errorMessage: AppStrings.unknownError,
      ));
    }
  }

  Future<void> _onExportRequested(
    PrivacyExportRequested event,
    Emitter<PrivacyState> emit,
  ) async {
    final current = state;
    if (current is! PrivacyLoaded) return;

    emit(current.copyWith(isSaving: true));

    try {
      await _repository.requestDataExport();
      emit(current.copyWith(
        isSaving: false,
        successMessage: AppStrings.exportRequestSent,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(
        isSaving: false,
        errorMessage: AppStrings.unknownError,
      ));
    }
  }

  Future<void> _onDeleteRequested(
    PrivacyDeleteRequested event,
    Emitter<PrivacyState> emit,
  ) async {
    final current = state;
    if (current is! PrivacyLoaded) return;

    emit(current.copyWith(isSaving: true));

    try {
      final result = await _repository.requestDataDeletion(
        'full',
        event.reason,
      );
      emit(current.copyWith(
        isSaving: false,
        deleteStatus: result,
        successMessage: AppStrings.deleteRequestSent,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(isSaving: false, errorMessage: e.message));
    } catch (_) {
      emit(current.copyWith(
        isSaving: false,
        errorMessage: AppStrings.unknownError,
      ));
    }
  }

  void _onErrorCleared(
    PrivacyErrorCleared event,
    Emitter<PrivacyState> emit,
  ) {
    final current = state;
    if (current is PrivacyLoaded) {
      emit(current.copyWith(errorMessage: null, successMessage: null));
    }
  }
}
