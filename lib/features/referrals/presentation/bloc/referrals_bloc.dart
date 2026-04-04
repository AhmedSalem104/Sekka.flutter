import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../data/models/referral_model.dart';
import '../../data/models/referral_stats_model.dart';
import '../../data/repositories/referral_repository.dart';
import 'referrals_event.dart';
import 'referrals_state.dart';

class ReferralsBloc extends HydratedBloc<ReferralsEvent, ReferralsState> {
  ReferralsBloc({required ReferralRepository repository})
      : _repository = repository,
        super(const ReferralsInitial()) {
    on<ReferralsLoadRequested>(_onLoad);
    on<ReferralsRefreshRequested>(_onRefresh);
  }

  final ReferralRepository _repository;

  Future<void> _onLoad(
    ReferralsLoadRequested event,
    Emitter<ReferralsState> emit,
  ) async {
    if (state is! ReferralsLoaded) {
      emit(const ReferralsLoading());
    }

    await _fetchAll(emit);
  }

  Future<void> _onRefresh(
    ReferralsRefreshRequested event,
    Emitter<ReferralsState> emit,
  ) async {
    await _fetchAll(emit);
  }

  Future<void> _fetchAll(Emitter<ReferralsState> emit) async {
    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getReferrals(),
        _repository.getMyCode(),
      ]);

      final statsResult = results[0] as ApiResult<ReferralStatsModel>;
      final listResult = results[1] as ApiResult<List<ReferralModel>>;
      final codeResult = results[2] as ApiResult<String>;

      final stats = switch (statsResult) {
        ApiSuccess(:final data) => data,
        ApiFailure() => const ReferralStatsModel(
            totalReferrals: 0,
            activeReferrals: 0,
            totalEarnings: 0,
            pendingRewards: 0,
          ),
      };

      final referrals = switch (listResult) {
        ApiSuccess(:final data) => data,
        ApiFailure() => <ReferralModel>[],
      };

      final code = switch (codeResult) {
        ApiSuccess(:final data) => data,
        ApiFailure() => state is ReferralsLoaded
            ? (state as ReferralsLoaded).code
            : '',
      };

      emit(ReferralsLoaded(
        stats: stats,
        referrals: referrals,
        code: code,
      ));
    } catch (_) {
      if (state is! ReferralsLoaded) {
        emit(const ReferralsError('مقدرش أجيب بيانات الدعوات — جرّب تاني'));
      }
    }
  }

  // ── Hydration ──

  @override
  ReferralsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        return ReferralsLoaded(
          stats: ReferralStatsModel.fromJson(
            Map<String, dynamic>.from(json['stats'] as Map),
          ),
          referrals: (json['referrals'] as List<dynamic>)
              .map((e) => ReferralModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList(),
          code: json['code'] as String? ?? '',
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ReferralsState state) {
    if (state is ReferralsLoaded) {
      return {
        'type': 'loaded',
        'stats': state.stats.toJson(),
        'referrals': state.referrals.map((r) => r.toJson()).toList(),
        'code': state.code,
      };
    }
    return null;
  }
}
