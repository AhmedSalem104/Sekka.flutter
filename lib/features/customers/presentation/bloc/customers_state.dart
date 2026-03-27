import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';

sealed class CustomersState extends Equatable {
  const CustomersState();
  @override
  List<Object?> get props => [];
}

final class CustomersInitial extends CustomersState {
  const CustomersInitial();
}

final class CustomersLoading extends CustomersState {
  const CustomersLoading();
}

final class CustomersLoaded extends CustomersState {
  const CustomersLoaded({
    required this.customers,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });
  final List<CustomerModel> customers;
  final int totalCount;
  final int page;
  final bool hasNextPage;
  @override
  List<Object?> get props => [customers, totalCount, page, hasNextPage];
}

final class CustomersError extends CustomersState {
  const CustomersError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
