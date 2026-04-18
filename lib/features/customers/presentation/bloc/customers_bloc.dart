import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../../shared/network/api_result.dart';
import '../../../search/data/repositories/search_repository.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends HydratedBloc<CustomersEvent, CustomersState> {
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
    // Only show loading spinner if no cached data
    if (state is! CustomersLoaded) {
      emit(const CustomersLoading());
    }

    final result = await _repository.getCustomers(
      pageNumber: event.page,
      pageSize: 100,
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
        // Keep cached data on failure
        if (state is! CustomersLoaded) {
          emit(CustomersError(message: error.arabicMessage));
        }
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

  // ── Hydration ──

  @override
  CustomersState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final customers = (json['customers'] as List<dynamic>)
            .map((c) => CustomerModel.fromJson(
                  Map<String, dynamic>.from(c as Map),
                ))
            .toList();
        return CustomersLoaded(
          customers: customers,
          totalCount: json['totalCount'] as int? ?? customers.length,
          page: json['page'] as int? ?? 1,
          hasNextPage: json['hasNextPage'] as bool? ?? false,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(CustomersState state) {
    if (state is CustomersLoaded) {
      return {
        'type': 'loaded',
        'customers': state.customers.map((c) => c.toJson()).toList(),
        'totalCount': state.totalCount,
        'page': state.page,
        'hasNextPage': state.hasNextPage,
      };
    }
    return null;
  }
}
