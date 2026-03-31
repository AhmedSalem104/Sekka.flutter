import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../../search/data/repositories/search_repository.dart';
import '../../data/models/partner_model.dart';
import '../../data/repositories/partner_repository.dart';
import 'partners_event.dart';
import 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersBloc({
    required PartnerRepository repository,
    SearchRepository? searchRepository,
  })  : _repository = repository,
        _searchRepository = searchRepository,
        super(const PartnersInitial()) {
    on<PartnersLoadRequested>(_onLoad);
    on<PartnersSearchChanged>(_onSearchChanged);
  }

  final PartnerRepository _repository;
  final SearchRepository? _searchRepository;

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

  Future<void> _onSearchChanged(
    PartnersSearchChanged event,
    Emitter<PartnersState> emit,
  ) async {
    final term = event.searchTerm.trim();

    // Empty search → reload all
    if (term.isEmpty) {
      add(const PartnersLoadRequested());
      return;
    }

    if (_searchRepository != null) {
      emit(const PartnersLoading());
      final result = await _searchRepository.search(query: term);
      switch (result) {
        case ApiSuccess(:final data):
          final partners = data.partners
              .map((p) => PartnerModel(
                    id: p.id,
                    name: p.name,
                    partnerType: p.partnerType ?? 0,
                    phone: p.phone,
                    commissionType: 0,
                    commissionValue: 0.0,
                    color: p.color ?? '#FC5D01',
                    isActive: true,
                    verificationStatus: 0,
                  ))
              .toList();
          emit(PartnersLoaded(
            partners: partners,
            totalCount: partners.length,
            page: 1,
            hasNextPage: false,
          ));
        case ApiFailure(:final error):
          emit(PartnersError(message: error.arabicMessage));
      }
    } else {
      add(PartnersLoadRequested(
        searchTerm: term,
      ));
    }
  }
}
