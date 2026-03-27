import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../data/repositories/partner_repository.dart';
import 'partners_event.dart';
import 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersBloc({required PartnerRepository repository})
      : _repository = repository,
        super(const PartnersInitial()) {
    on<PartnersLoadRequested>(_onLoad);
    on<PartnersSearchChanged>(_onSearchChanged);
  }

  final PartnerRepository _repository;

  Future<void> _onLoad(
    PartnersLoadRequested event,
    Emitter<PartnersState> emit,
  ) async {
    emit(const PartnersLoading());

    final result = await _repository.getPartners(
      pageNumber: event.page,
      searchTerm: event.searchTerm,
      partnerType: event.partnerType,
      isActive: event.isActive,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(PartnersLoaded(
          partners: data,
          totalCount: data.length,
          page: event.page,
          hasNextPage: false,
        ));
      case ApiFailure(:final error):
        emit(PartnersError(message: error.arabicMessage));
    }
  }

  void _onSearchChanged(
    PartnersSearchChanged event,
    Emitter<PartnersState> emit,
  ) {
    add(PartnersLoadRequested(
      searchTerm: event.searchTerm.isEmpty ? null : event.searchTerm,
    ));
  }
}
