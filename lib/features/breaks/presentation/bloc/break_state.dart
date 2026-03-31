part of 'break_bloc.dart';

sealed class BreakState extends Equatable {
  const BreakState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any check.
final class BreakInitial extends BreakState {
  const BreakInitial();
}

/// Loading suggestion / active break check.
final class BreakCheckLoading extends BreakState {
  const BreakCheckLoading();
}

/// Home screen state: holds suggestion and optional active break.
final class BreakCheckLoaded extends BreakState {
  const BreakCheckLoaded({
    this.suggestion,
    this.activeBreak,
  });

  final BreakSuggestionEntity? suggestion;
  final BreakEntity? activeBreak;

  BreakCheckLoaded copyWith({
    BreakSuggestionEntity? suggestion,
    BreakEntity? activeBreak,
    bool clearActive = false,
    bool clearSuggestion = false,
  }) {
    return BreakCheckLoaded(
      suggestion: clearSuggestion ? null : (suggestion ?? this.suggestion),
      activeBreak: clearActive ? null : (activeBreak ?? this.activeBreak),
    );
  }

  @override
  List<Object?> get props => [suggestion, activeBreak];
}

/// A break start is in progress.
final class BreakStarting extends BreakState {
  const BreakStarting();
}

/// A break was successfully started.
final class BreakStarted extends BreakState {
  const BreakStarted({required this.breakEntity});

  final BreakEntity breakEntity;

  @override
  List<Object?> get props => [breakEntity];
}

/// A break end is in progress.
final class BreakEnding extends BreakState {
  const BreakEnding();
}

/// A break was successfully ended.
final class BreakEnded extends BreakState {
  const BreakEnded({required this.breakEntity});

  final BreakEntity breakEntity;

  @override
  List<Object?> get props => [breakEntity];
}

/// Loading history.
final class BreakHistoryLoading extends BreakState {
  const BreakHistoryLoading();
}

/// History loaded.
final class BreakHistoryLoaded extends BreakState {
  const BreakHistoryLoaded({
    required this.breaks,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  final List<BreakEntity> breaks;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  BreakHistoryLoaded copyWith({
    List<BreakEntity>? breaks,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return BreakHistoryLoaded(
      breaks: breaks ?? this.breaks,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [breaks, hasMore, currentPage, isLoadingMore];
}

/// Error state.
final class BreakError extends BreakState {
  const BreakError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
