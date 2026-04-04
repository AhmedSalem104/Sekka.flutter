import 'package:equatable/equatable.dart';

import '../../domain/entities/shift_entity.dart';
import '../../domain/entities/shift_summary_entity.dart';

sealed class ShiftState extends Equatable {
  const ShiftState();

  @override
  List<Object?> get props => [];
}

final class ShiftInitial extends ShiftState {
  const ShiftInitial();
}

final class ShiftLoading extends ShiftState {
  const ShiftLoading();
}

/// Main loaded state — holds current shift (nullable) and summary.
final class ShiftLoaded extends ShiftState {
  ShiftLoaded({
    this.currentShift,
    this.summary,
    this.isToggling = false,
  }) : lastCheckedAt = DateTime.now();

  final ShiftEntity? currentShift;
  final ShiftSummaryEntity? summary;
  final bool isToggling;
  final DateTime lastCheckedAt;

  bool get isActive => currentShift?.isActive ?? false;

  ShiftLoaded copyWith({
    ShiftEntity? currentShift,
    ShiftSummaryEntity? summary,
    bool? isToggling,
    bool clearShift = false,
  }) {
    return ShiftLoaded(
      currentShift: clearShift ? null : (currentShift ?? this.currentShift),
      summary: summary ?? this.summary,
      isToggling: isToggling ?? this.isToggling,
    );
  }

  @override
  List<Object?> get props => [currentShift, summary, isToggling, lastCheckedAt];
}

final class ShiftError extends ShiftState {
  const ShiftError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
