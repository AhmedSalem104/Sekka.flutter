import 'package:equatable/equatable.dart';

sealed class ReferralsEvent extends Equatable {
  const ReferralsEvent();
  @override
  List<Object?> get props => [];
}

final class ReferralsLoadRequested extends ReferralsEvent {
  const ReferralsLoadRequested();
}

final class ReferralsRefreshRequested extends ReferralsEvent {
  const ReferralsRefreshRequested();
}
