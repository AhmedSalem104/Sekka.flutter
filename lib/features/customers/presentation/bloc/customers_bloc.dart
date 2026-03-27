import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/repositories/customer_repository.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  CustomersBloc({required CustomerRepository repository})
      : _repository = repository,
        super(const CustomersInitial()) {
    on<CustomersLoadRequested>(_onLoadRequested);
    on<CustomersSearchChanged>(_onSearchChanged);
  }

  final CustomerRepository _repository;

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
    add(CustomersLoadRequested(searchTerm: event.searchTerm));
  }
}
