import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/customer_detail_model.dart';
import '../../data/models/create_rating_model.dart';
import '../../data/repositories/customer_repository.dart';

// ── Events ──

sealed class CustomerDetailEvent extends Equatable {
  const CustomerDetailEvent();
  @override
  List<Object?> get props => [];
}

final class CustomerDetailLoadRequested extends CustomerDetailEvent {
  const CustomerDetailLoadRequested(this.customerId);
  final String customerId;
  @override
  List<Object?> get props => [customerId];
}

final class CustomerRateRequested extends CustomerDetailEvent {
  const CustomerRateRequested({
    required this.customerId,
    required this.rating,
  });
  final String customerId;
  final CreateRatingModel rating;
  @override
  List<Object?> get props => [customerId, rating];
}

final class CustomerBlockRequested extends CustomerDetailEvent {
  const CustomerBlockRequested({
    required this.customerId,
    required this.reason,
    this.reportToCommunity = false,
  });
  final String customerId;
  final String reason;
  final bool reportToCommunity;
  @override
  List<Object?> get props => [customerId, reason, reportToCommunity];
}

final class CustomerUnblockRequested extends CustomerDetailEvent {
  const CustomerUnblockRequested(this.customerId);
  final String customerId;
  @override
  List<Object?> get props => [customerId];
}

// ── States ──

sealed class CustomerDetailState extends Equatable {
  const CustomerDetailState();
  @override
  List<Object?> get props => [];
}

final class CustomerDetailInitial extends CustomerDetailState {
  const CustomerDetailInitial();
}

final class CustomerDetailLoading extends CustomerDetailState {
  const CustomerDetailLoading();
}

final class CustomerDetailLoaded extends CustomerDetailState {
  const CustomerDetailLoaded({required this.customer});
  final CustomerDetailModel customer;
  @override
  List<Object?> get props => [customer];
}

final class CustomerDetailError extends CustomerDetailState {
  const CustomerDetailError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

final class CustomerDetailActionSuccess extends CustomerDetailState {
  const CustomerDetailActionSuccess({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──

class CustomerDetailBloc
    extends Bloc<CustomerDetailEvent, CustomerDetailState> {
  CustomerDetailBloc({required CustomerRepository repository})
      : _repository = repository,
        super(const CustomerDetailInitial()) {
    on<CustomerDetailLoadRequested>(_onLoad);
    on<CustomerRateRequested>(_onRate);
    on<CustomerBlockRequested>(_onBlock);
    on<CustomerUnblockRequested>(_onUnblock);
  }

  final CustomerRepository _repository;

  Future<void> _onLoad(
    CustomerDetailLoadRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(const CustomerDetailLoading());

    final result = await _repository.getCustomer(event.customerId);

    switch (result) {
      case ApiSuccess(:final data):
        emit(CustomerDetailLoaded(customer: data));
      case ApiFailure(:final error):
        emit(CustomerDetailError(message: error.arabicMessage));
    }
  }

  Future<void> _onRate(
    CustomerRateRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final result = await _repository.rateCustomer(
      event.customerId,
      rating: event.rating,
    );

    switch (result) {
      case ApiSuccess():
        emit(const CustomerDetailActionSuccess(
          message: 'تم تقييم العميل بنجاح',
        ));
        add(CustomerDetailLoadRequested(event.customerId));
      case ApiFailure(:final error):
        emit(CustomerDetailError(message: error.arabicMessage));
    }
  }

  Future<void> _onBlock(
    CustomerBlockRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final result = await _repository.blockCustomer(
      event.customerId,
      reason: event.reason,
      reportToCommunity: event.reportToCommunity,
    );

    switch (result) {
      case ApiSuccess():
        emit(const CustomerDetailActionSuccess(
          message: 'تم حظر العميل بنجاح',
        ));
        add(CustomerDetailLoadRequested(event.customerId));
      case ApiFailure(:final error):
        emit(CustomerDetailError(message: error.arabicMessage));
    }
  }

  Future<void> _onUnblock(
    CustomerUnblockRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final result = await _repository.unblockCustomer(event.customerId);

    switch (result) {
      case ApiSuccess():
        emit(const CustomerDetailActionSuccess(
          message: 'تم إلغاء حظر العميل بنجاح',
        ));
        add(CustomerDetailLoadRequested(event.customerId));
      case ApiFailure(:final error):
        emit(CustomerDetailError(message: error.arabicMessage));
    }
  }
}
