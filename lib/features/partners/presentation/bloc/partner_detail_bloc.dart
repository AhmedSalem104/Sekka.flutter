import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/partner_model.dart';
import '../../data/models/partner_order_model.dart';
import '../../data/models/pickup_point_model.dart';
import '../../data/repositories/partner_repository.dart';

// ── Events ──

sealed class PartnerDetailEvent extends Equatable {
  const PartnerDetailEvent();
  @override
  List<Object?> get props => [];
}

final class PartnerDetailLoadRequested extends PartnerDetailEvent {
  const PartnerDetailLoadRequested({required this.partner});
  final PartnerModel partner;
  @override
  List<Object?> get props => [partner.id];
}

// ── States ──

sealed class PartnerDetailState extends Equatable {
  const PartnerDetailState();
  @override
  List<Object?> get props => [];
}

final class PartnerDetailInitial extends PartnerDetailState {
  const PartnerDetailInitial();
}

final class PartnerDetailLoading extends PartnerDetailState {
  const PartnerDetailLoading();
}

final class PartnerDetailLoaded extends PartnerDetailState {
  const PartnerDetailLoaded({
    required this.partner,
    required this.pickupPoints,
    required this.orders,
  });
  final PartnerModel partner;
  final List<PickupPointModel> pickupPoints;
  final PagedData<PartnerOrderModel> orders;
  @override
  List<Object?> get props => [partner.id, pickupPoints, orders];
}

final class PartnerDetailError extends PartnerDetailState {
  const PartnerDetailError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──

class PartnerDetailBloc
    extends Bloc<PartnerDetailEvent, PartnerDetailState> {
  PartnerDetailBloc({required PartnerRepository repository})
      : _repository = repository,
        super(const PartnerDetailInitial()) {
    on<PartnerDetailLoadRequested>(_onLoad);
  }

  final PartnerRepository _repository;

  Future<void> _onLoad(
    PartnerDetailLoadRequested event,
    Emitter<PartnerDetailState> emit,
  ) async {
    emit(const PartnerDetailLoading());

    try {
      final results = await Future.wait([
        _repository.getPickupPoints(event.partner.id),
        _repository.getPartnerOrders(event.partner.id),
      ]);

      final pickupResult = results[0] as ApiResult<List<PickupPointModel>>;
      final ordersResult =
          results[1] as ApiResult<PagedData<PartnerOrderModel>>;

      switch ((pickupResult, ordersResult)) {
        case (
            ApiSuccess(data: final pickupPoints),
            ApiSuccess(data: final orders),
          ):
          emit(PartnerDetailLoaded(
            partner: event.partner,
            pickupPoints: pickupPoints,
            orders: orders,
          ));
        case (ApiFailure(:final error), _):
          emit(PartnerDetailError(message: error.arabicMessage));
        case (_, ApiFailure(:final error)):
          emit(PartnerDetailError(message: error.arabicMessage));
      }
    } catch (_) {
      // Offline: show partner info we have with empty lists
      emit(PartnerDetailLoaded(
        partner: event.partner,
        pickupPoints: const [],
        orders: const PagedData(items: [], totalCount: 0, page: 1, pageSize: 20, totalPages: 0),
      ));
    }
  }
}
