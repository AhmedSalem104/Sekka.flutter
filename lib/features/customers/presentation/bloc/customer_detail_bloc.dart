import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/customer_behavior_model.dart';
import '../../data/models/customer_detail_model.dart';
import '../../data/models/customer_engagement_model.dart';
import '../../data/models/customer_insights_profile_model.dart';
import '../../data/models/customer_interests_model.dart';
import '../../data/models/customer_order_model.dart';
import '../../data/models/customer_recommendation_model.dart';
import '../../data/models/create_rating_model.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/customer_insights_repository.dart';

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

final class RecommendationReadRequested extends CustomerDetailEvent {
  const RecommendationReadRequested({
    required this.customerId,
    required this.recommendationId,
  });
  final String customerId;
  final String recommendationId;
  @override
  List<Object?> get props => [customerId, recommendationId];
}

final class RecommendationDismissRequested extends CustomerDetailEvent {
  const RecommendationDismissRequested({
    required this.customerId,
    required this.recommendationId,
  });
  final String customerId;
  final String recommendationId;
  @override
  List<Object?> get props => [customerId, recommendationId];
}

final class RecommendationActRequested extends CustomerDetailEvent {
  const RecommendationActRequested({
    required this.customerId,
    required this.recommendationId,
  });
  final String customerId;
  final String recommendationId;
  @override
  List<Object?> get props => [customerId, recommendationId];
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
  const CustomerDetailLoaded({
    required this.customer,
    this.insightsProfile,
    this.engagement,
    this.interests,
    this.recommendations,
    this.orders,
    this.behavior,
    this.insightsInterests,
  });
  final CustomerDetailModel customer;
  final CustomerInsightsProfileModel? insightsProfile;
  final CustomerEngagementModel? engagement;
  final CustomerInterestsModel? interests;
  final List<CustomerRecommendationModel>? recommendations;
  final PagedData<CustomerOrderModel>? orders;
  final CustomerBehaviorModel? behavior;
  final List<Map<String, dynamic>>? insightsInterests;
  @override
  List<Object?> get props => [
        customer,
        insightsProfile,
        engagement,
        interests,
        recommendations,
        orders,
        behavior,
        insightsInterests,
      ];
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
  CustomerDetailBloc({
    required CustomerRepository repository,
    CustomerInsightsRepository? insightsRepository,
  })  : _repository = repository,
        _insightsRepository = insightsRepository,
        super(const CustomerDetailInitial()) {
    on<CustomerDetailLoadRequested>(_onLoad);
    on<CustomerRateRequested>(_onRate);
    on<CustomerBlockRequested>(_onBlock);
    on<CustomerUnblockRequested>(_onUnblock);
    on<RecommendationReadRequested>(_onRecommendationRead);
    on<RecommendationDismissRequested>(_onRecommendationDismiss);
    on<RecommendationActRequested>(_onRecommendationAct);
  }

  final CustomerRepository _repository;
  final CustomerInsightsRepository? _insightsRepository;

  Future<void> _onLoad(
    CustomerDetailLoadRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    emit(const CustomerDetailLoading());

    // Load customer detail (required)
    final detailResult = await _repository.getCustomer(event.customerId);

    switch (detailResult) {
      case ApiSuccess(:final data):
        // Load all extras in parallel
        final engagementFuture = _repository.getEngagement(event.customerId);
        final interestsFuture = _repository.getInterests(event.customerId);
        final ordersFuture = _repository.getCustomerOrders(event.customerId);
        final profileFuture =
            _insightsRepository?.getProfile(event.customerId);
        final recsFuture =
            _insightsRepository?.getRecommendations(event.customerId);
        final behaviorFuture =
            _insightsRepository?.getBehavior(event.customerId);
        final insightsInterestsFuture =
            _insightsRepository?.getInterests(event.customerId);

        await Future.wait([
          engagementFuture,
          interestsFuture,
          ordersFuture,
          if (profileFuture != null) profileFuture,
          if (recsFuture != null) recsFuture,
          if (behaviorFuture != null) behaviorFuture,
          if (insightsInterestsFuture != null) insightsInterestsFuture,
        ]);

        CustomerEngagementModel? engagement;
        CustomerInterestsModel? interests;
        PagedData<CustomerOrderModel>? orders;
        CustomerInsightsProfileModel? insightsProfile;
        List<CustomerRecommendationModel>? recommendations;
        CustomerBehaviorModel? behavior;
        List<Map<String, dynamic>>? insightsInterests;

        final engagementResult = await engagementFuture;
        if (engagementResult
            case ApiSuccess<CustomerEngagementModel>(:final data)) {
          engagement = data;
        }

        final interestsResult = await interestsFuture;
        if (interestsResult
            case ApiSuccess<CustomerInterestsModel>(:final data)) {
          interests = data;
        }

        final ordersResult = await ordersFuture;
        if (ordersResult
            case ApiSuccess<PagedData<CustomerOrderModel>>(:final data)) {
          orders = data;
        }

        if (profileFuture != null) {
          final profileResult = await profileFuture;
          if (profileResult
              case ApiSuccess<CustomerInsightsProfileModel>(:final data)) {
            insightsProfile = data;
          }
        }

        if (recsFuture != null) {
          final recsResult = await recsFuture;
          if (recsResult
              case ApiSuccess<List<CustomerRecommendationModel>>(
                :final data
              )) {
            recommendations = data;
          }
        }

        if (behaviorFuture != null) {
          final behaviorResult = await behaviorFuture;
          if (behaviorResult
              case ApiSuccess<CustomerBehaviorModel>(:final data)) {
            behavior = data;
          }
        }

        if (insightsInterestsFuture != null) {
          final iiResult = await insightsInterestsFuture;
          if (iiResult
              case ApiSuccess<List<Map<String, dynamic>>>(:final data)) {
            insightsInterests = data;
          }
        }

        emit(CustomerDetailLoaded(
          customer: data,
          engagement: engagement,
          interests: interests,
          orders: orders,
          insightsProfile: insightsProfile,
          recommendations: recommendations,
          behavior: behavior,
          insightsInterests: insightsInterests,
        ));
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

  Future<void> _onRecommendationRead(
    RecommendationReadRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    if (_insightsRepository == null) return;
    await _insightsRepository.markRecommendationRead(event.recommendationId);
    add(CustomerDetailLoadRequested(event.customerId));
  }

  Future<void> _onRecommendationDismiss(
    RecommendationDismissRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    if (_insightsRepository == null) return;
    await _insightsRepository.dismissRecommendation(event.recommendationId);
    add(CustomerDetailLoadRequested(event.customerId));
  }

  Future<void> _onRecommendationAct(
    RecommendationActRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    if (_insightsRepository == null) return;
    await _insightsRepository.actOnRecommendation(event.recommendationId);
    add(CustomerDetailLoadRequested(event.customerId));
  }
}
