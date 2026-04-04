import 'package:equatable/equatable.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

final class AnalyticsLoadRequested extends AnalyticsEvent {
  const AnalyticsLoadRequested();
}
