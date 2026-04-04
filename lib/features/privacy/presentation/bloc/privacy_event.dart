import 'package:equatable/equatable.dart';

sealed class PrivacyEvent extends Equatable {
  const PrivacyEvent();

  @override
  List<Object?> get props => [];
}

final class PrivacyLoadRequested extends PrivacyEvent {
  const PrivacyLoadRequested();
}

final class PrivacyConsentToggled extends PrivacyEvent {
  const PrivacyConsentToggled(this.consentType, this.isGranted);

  final String consentType;
  final bool isGranted;

  @override
  List<Object?> get props => [consentType, isGranted];
}

final class PrivacyExportRequested extends PrivacyEvent {
  const PrivacyExportRequested();
}

final class PrivacyDeleteRequested extends PrivacyEvent {
  const PrivacyDeleteRequested({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}

final class PrivacyErrorCleared extends PrivacyEvent {
  const PrivacyErrorCleared();
}
