import '../../domain/entities/profile_completion_entity.dart';

class ProfileCompletionModel extends ProfileCompletionEntity {
  const ProfileCompletionModel({
    required super.completionPercentage,
    required super.completedSteps,
    required super.pendingSteps,
    required super.isProfileComplete,
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      completedSteps: (json['completedSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pendingSteps: (json['pendingSteps'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PendingStepModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }
}

class PendingStepModel extends PendingStepEntity {
  const PendingStepModel({
    required super.stepName,
    required super.stepKey,
    required super.isRequired,
    required super.weight,
  });

  factory PendingStepModel.fromJson(Map<String, dynamic> json) {
    return PendingStepModel(
      stepName: json['stepName'] as String? ?? '',
      stepKey: json['stepKey'] as String? ?? '',
      isRequired: json['isRequired'] as bool? ?? false,
      weight: json['weight'] as int? ?? 0,
    );
  }
}
