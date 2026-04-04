import 'package:equatable/equatable.dart';

import '../../domain/entities/consent_entity.dart';

sealed class PrivacyState extends Equatable {
  const PrivacyState();

  @override
  List<Object?> get props => [];
}

final class PrivacyInitial extends PrivacyState {
  const PrivacyInitial();
}

final class PrivacyLoading extends PrivacyState {
  const PrivacyLoading();
}

final class PrivacyLoaded extends PrivacyState {
  const PrivacyLoaded({
    required this.consents,
    this.deleteStatus,
    this.isSaving = false,
    this.successMessage,
    this.errorMessage,
  });

  final List<ConsentEntity> consents;
  final DataRequestEntity? deleteStatus;
  final bool isSaving;
  final String? successMessage;
  final String? errorMessage;

  PrivacyLoaded copyWith({
    List<ConsentEntity>? consents,
    DataRequestEntity? deleteStatus,
    bool? isSaving,
    String? successMessage,
    String? errorMessage,
  }) {
    return PrivacyLoaded(
      consents: consents ?? this.consents,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      isSaving: isSaving ?? this.isSaving,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  bool consentGranted(String type) {
    final consent = consents.where((c) => c.consentType == type).firstOrNull;
    return consent?.isGranted ?? false;
  }

  @override
  List<Object?> get props => [
        consents,
        deleteStatus,
        isSaving,
        successMessage,
        errorMessage,
      ];
}

final class PrivacyError extends PrivacyState {
  const PrivacyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
