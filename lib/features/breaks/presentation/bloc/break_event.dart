part of 'break_bloc.dart';

sealed class BreakEvent extends Equatable {
  const BreakEvent();

  @override
  List<Object?> get props => [];
}

/// Load break suggestion + active break from API.
final class BreakCheckRequested extends BreakEvent {
  const BreakCheckRequested();
}

/// Start a new break.
final class BreakStartRequested extends BreakEvent {
  const BreakStartRequested({
    required this.energyBefore,
    required this.locationDescription,
  });

  final int energyBefore;
  final String locationDescription;

  @override
  List<Object?> get props => [energyBefore, locationDescription];
}

/// End the active break.
final class BreakEndRequested extends BreakEvent {
  const BreakEndRequested({required this.energyAfter});

  final int energyAfter;

  @override
  List<Object?> get props => [energyAfter];
}

/// Load break history (first page or refresh).
final class BreakHistoryRequested extends BreakEvent {
  const BreakHistoryRequested({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

/// Load next page of break history.
final class BreakHistoryNextPage extends BreakEvent {
  const BreakHistoryNextPage();
}
