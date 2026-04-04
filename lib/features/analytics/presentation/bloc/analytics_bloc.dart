import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(const AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoad);
  }

  final AnalyticsRepository _repository;

  Future<void> _onLoad(
    AnalyticsLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final (
        sourceBreakdown,
        customerProfitability,
        regionAnalysis,
        timeAnalysis,
        cancellationReport,
        profitabilityTrends,
      ) = await (
        _repository.getSourceBreakdown(),
        _repository.getCustomerProfitability(),
        _repository.getRegionAnalysis(),
        _repository.getTimeAnalysis(),
        _repository.getCancellationReport(),
        _repository.getProfitabilityTrends(),
      ).wait;

      emit(AnalyticsLoaded(
        sourceBreakdown: sourceBreakdown,
        customerProfitability: customerProfitability,
        regionAnalysis: regionAnalysis,
        timeAnalysis: timeAnalysis,
        cancellationReport: cancellationReport,
        profitabilityTrends: profitabilityTrends,
      ));
    } on ApiException catch (e) {
      emit(AnalyticsError(e.message));
    } on ParallelWaitError<dynamic, dynamic> catch (_) {
      emit(AnalyticsError(AppStrings.unknownError));
    } catch (_) {
      emit(AnalyticsError(AppStrings.unknownError));
    }
  }
}
