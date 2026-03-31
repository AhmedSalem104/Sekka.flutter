import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/network/api_result.dart';
import '../../../search/data/repositories/search_repository.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  CustomersBloc({
    required CustomerRepository repository,
    SearchRepository? searchRepository,
  })  : _repository = repository,
        _searchRepository = searchRepository,
        super(const CustomersInitial()) {
    on<CustomersLoadRequested>(_onLoadRequested);
    on<CustomersSearchChanged>(_onSearchChanged);
  }

  final CustomerRepository _repository;
  final SearchRepository? _searchRepository;

  Future<void> _onLoadRequested(
    CustomersLoadRequested event,
    Emitter<CustomersState> emit,
  ) async {
    emit(const CustomersLoading());

    final result = await _repository.getCustomers(
      pageNumber: event.page,
      pageSize: 10,
      searchTerm: event.searchTerm,
      isBlocked: event.isBlocked,
      minRating: event.minRating,
      sortBy: event.sortBy,
    );

    switch (result) {
      case ApiSuccess(:final data):
        emit(CustomersLoaded(
          customers: data.items,
          totalCount: data.totalCount,
          page: data.page,
          hasNextPage: data.hasNextPage,
        ));
      case ApiFailure(:final error):
        emit(CustomersError(message: error.arabicMessage));
    }
  }

  Future<void> _onSearchChanged(
    CustomersSearchChanged event,
    Emitter<CustomersState> emit,
  ) async {
    final term = event.searchTerm.trim();

    // Empty search → reload all
    if (term.isEmpty) {
      add(const CustomersLoadRequested());
      return;
    }

    if (_searchRepository != null) {
      emit(const CustomersLoading());
      final result = await _searchRepository.search(query: term);
      switch (result) {
        case ApiSuccess(:final data):
          final customers = data.customers
              .map((c) => CustomerModel(
                    id: c.id,
                    phone: c.phone,
                    name: c.name,
                    averageRating: c.averageRating ?? 0.0,
                    totalDeliveries: c.totalDeliveries ?? 0,
                    successfulDeliveries: 0,
                    isBlocked: false,
                  ))
              .toList();
          emit(CustomersLoaded(
            customers: customers,
            totalCount: customers.length,
            page: 1,
            hasNextPage: false,
          ));
        case ApiFailure(:final error):
          emit(CustomersError(message: error.arabicMessage));
      }
    } else {
      add(CustomersLoadRequested(searchTerm: term));
    }
  }
}
