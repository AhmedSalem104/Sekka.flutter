import 'package:equatable/equatable.dart';

sealed class ShiftEvent extends Equatable {
  const ShiftEvent();

  @override
  List<Object?> get props => [];
}

final class ShiftCheckRequested extends ShiftEvent {
  const ShiftCheckRequested();
}

final class ShiftStartRequested extends ShiftEvent {
  const ShiftStartRequested();
}

final class ShiftEndRequested extends ShiftEvent {
  const ShiftEndRequested();
}

final class ShiftSummaryRequested extends ShiftEvent {
  const ShiftSummaryRequested();
}
