import 'package:equatable/equatable.dart';

class ProfileCompletionEntity extends Equatable {
  const ProfileCompletionEntity({
    required this.completionPercentage,
    required this.completedSteps,
    required this.pendingSteps,
    required this.isProfileComplete,
  });

  final int completionPercentage;
  final List<String> completedSteps;
  final List<PendingStepEntity> pendingSteps;
  final bool isProfileComplete;

  @override
  List<Object?> get props => [
        completionPercentage,
        completedSteps,
        pendingSteps,
        isProfileComplete,
      ];
}

class PendingStepEntity extends Equatable {
  const PendingStepEntity({
    required this.stepName,
    required this.stepKey,
    required this.isRequired,
    required this.weight,
  });

  final String stepName;
  final String stepKey;
  final bool isRequired;
  final int weight;

  @override
  List<Object?> get props => [stepName, stepKey, isRequired, weight];
}
