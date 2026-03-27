import 'package:equatable/equatable.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

final class WalletLoadRequested extends WalletEvent {
  const WalletLoadRequested();
}

final class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}

final class WalletNextPageRequested extends WalletEvent {
  const WalletNextPageRequested();
}

final class WalletFilterChanged extends WalletEvent {
  const WalletFilterChanged(this.filterIndex);

  /// 0 = all, 1 = income, 2 = expenses, 3 = settlements
  final int filterIndex;

  @override
  List<Object?> get props => [filterIndex];
}
