import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_type_entity.dart';

enum AuthFormStatus { initial, loading, success, failure }

class AuthFormState extends Equatable {
  const AuthFormState({
    this.activeTab = 0,
    this.status = AuthFormStatus.initial,
    this.otpCountdownSeconds = 0,
    this.canResendOtp = false,
    this.vehicleTypes = const [],
    this.errorMessage,
  });

  final int activeTab;
  final AuthFormStatus status;
  final int otpCountdownSeconds;
  final bool canResendOtp;
  final List<VehicleTypeEntity> vehicleTypes;
  final String? errorMessage;

  bool get isLoading => status == AuthFormStatus.loading;

  AuthFormState copyWith({
    int? activeTab,
    AuthFormStatus? status,
    int? otpCountdownSeconds,
    bool? canResendOtp,
    List<VehicleTypeEntity>? vehicleTypes,
    String? Function()? errorMessage,
  }) {
    return AuthFormState(
      activeTab: activeTab ?? this.activeTab,
      status: status ?? this.status,
      otpCountdownSeconds: otpCountdownSeconds ?? this.otpCountdownSeconds,
      canResendOtp: canResendOtp ?? this.canResendOtp,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        activeTab,
        status,
        otpCountdownSeconds,
        canResendOtp,
        vehicleTypes,
        errorMessage,
      ];
}
