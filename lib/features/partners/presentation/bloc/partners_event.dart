import 'package:equatable/equatable.dart';

sealed class PartnersEvent extends Equatable {
  const PartnersEvent();
  @override
  List<Object?> get props => [];
}

final class PartnersLoadRequested extends PartnersEvent {
  const PartnersLoadRequested({
    this.page = 1,
    this.searchTerm,
    this.partnerType,
    this.isActive,
  });
  final int page;
  final String? searchTerm;
  final int? partnerType;
  final bool? isActive;
  @override
  List<Object?> get props => [page, searchTerm, partnerType, isActive];
}

final class PartnersSearchChanged extends PartnersEvent {
  const PartnersSearchChanged(this.searchTerm);
  final String searchTerm;
  @override
  List<Object?> get props => [searchTerm];
}
