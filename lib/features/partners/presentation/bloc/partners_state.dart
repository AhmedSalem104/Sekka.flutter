import 'package:equatable/equatable.dart';
import '../../data/models/partner_model.dart';

sealed class PartnersState extends Equatable {
  const PartnersState();
  @override
  List<Object?> get props => [];
}

final class PartnersInitial extends PartnersState {
  const PartnersInitial();
}

final class PartnersLoading extends PartnersState {
  const PartnersLoading();
}

final class PartnersLoaded extends PartnersState {
  const PartnersLoaded({
    required this.partners,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });
  final List<PartnerModel> partners;
  final int totalCount;
  final int page;
  final bool hasNextPage;
  @override
  List<Object?> get props => [partners, totalCount, page, hasNextPage];
}

final class PartnersError extends PartnersState {
  const PartnersError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
