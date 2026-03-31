import 'package:equatable/equatable.dart';

sealed class BadgeEvent extends Equatable {
  const BadgeEvent();

  @override
  List<Object?> get props => [];
}

final class BadgeLoadRequested extends BadgeEvent {
  const BadgeLoadRequested();
}

final class BadgeVerifyRequested extends BadgeEvent {
  const BadgeVerifyRequested({required this.qrToken});
  final String qrToken;

  @override
  List<Object?> get props => [qrToken];
}
