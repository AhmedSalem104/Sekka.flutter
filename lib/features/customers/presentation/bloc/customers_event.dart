import 'package:equatable/equatable.dart';

sealed class CustomersEvent extends Equatable {
  const CustomersEvent();
  @override
  List<Object?> get props => [];
}

final class CustomersLoadRequested extends CustomersEvent {
  const CustomersLoadRequested({
    this.page = 1,
    this.searchTerm,
    this.isBlocked,
    this.minRating,
    this.sortBy,
  });
  final int page;
  final String? searchTerm;
  final bool? isBlocked;
  final double? minRating;
  final String? sortBy;
  @override
  List<Object?> get props => [page, searchTerm, isBlocked, minRating, sortBy];
}

final class CustomersSearchChanged extends CustomersEvent {
  const CustomersSearchChanged(this.searchTerm);
  final String searchTerm;
  @override
  List<Object?> get props => [searchTerm];
}
