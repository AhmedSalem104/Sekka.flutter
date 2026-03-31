import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/offline/offline_queue_service.dart';
import '../../../../shared/offline/queue_operation.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../data/models/profile_completion_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/profile_stats_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends HydratedBloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileRefreshRequested>(_onRefresh);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfileImageUploadRequested>(_onImageUpload);
    on<ProfileImageDeleteRequested>(_onImageDelete);
    on<LicenseImageUploadRequested>(_onLicenseUpload);
  }

  final ProfileRepository _repository;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) {
      emit(const ProfileLoading());
    }
    try {
      final (profile, completion, stats) = await (
        _repository.getProfile(),
        _repository.getCompletion(),
        _repository.getStats(),
      ).wait;

      emit(ProfileLoaded(
        profile: profile,
        completion: completion,
        stats: stats,
      ));
    } on ApiException catch (e) {
      if (current is! ProfileLoaded) emit(ProfileError(e.message));
    } catch (_) {
      if (current is! ProfileLoaded) emit(ProfileError(AppStrings.unknownError));
    }
  }

  Future<void> _onRefresh(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final (profile, completion, stats) = await (
        _repository.getProfile(),
        _repository.getCompletion(),
        _repository.getStats(),
      ).wait;

      emit(ProfileLoaded(
        profile: profile,
        completion: completion,
        stats: stats,
      ));
    } on ApiException {
      // Keep existing cached data on network failure
    } catch (_) {
      // Keep existing cached data on unexpected error
    }
  }

  Future<void> _onUpdate(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));

    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.profileUpdate,
        orderId: '',
        payload: event.updates,
      );
      emit(current.copyWith(isUpdating: false));
      return;
    }

    try {
      final profile = await _repository.updateProfile(event.updates);
      final completion = await _repository.getCompletion();

      emit(current.copyWith(
        profile: profile,
        completion: completion,
        isUpdating: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(isUpdating: false));
      emit(ProfileError(e.message));
    } catch (_) {
      emit(current.copyWith(isUpdating: false));
    }
  }

  Future<void> _onImageUpload(
    ProfileImageUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));

    try {
      final imagePath = await _repository.uploadProfileImage(event.imageFile);
      final profile = await _repository.getProfile();
      final completion = await _repository.getCompletion();

      // Backend may not return imageUrl in GET /profile yet,
      // so use the path from upload response as fallback.
      final effectiveProfile = profile.profileImageUrl != null
          ? profile
          : _withImageUrl(profile, imagePath);

      emit(current.copyWith(
        profile: effectiveProfile,
        completion: completion,
        isUpdating: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(isUpdating: false));
      emit(ProfileError(e.message));
    } catch (_) {
      emit(current.copyWith(isUpdating: false));
    }
  }

  Future<void> _onImageDelete(
    ProfileImageDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));

    try {
      await _repository.deleteProfileImage();
      final profile = await _repository.getProfile();
      final completion = await _repository.getCompletion();

      emit(current.copyWith(
        profile: profile,
        completion: completion,
        isUpdating: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(isUpdating: false));
      emit(ProfileError(e.message));
    } catch (_) {
      emit(current.copyWith(isUpdating: false));
    }
  }

  Future<void> _onLicenseUpload(
    LicenseImageUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));

    try {
      final licensePath = await _repository.uploadLicenseImage(event.imageFile);
      final profile = await _repository.getProfile();
      final completion = await _repository.getCompletion();

      final effectiveProfile = profile.licenseImageUrl != null
          ? profile
          : _withLicenseUrl(profile, licensePath);

      emit(current.copyWith(
        profile: effectiveProfile,
        completion: completion,
        isUpdating: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(isUpdating: false));
      emit(ProfileError(e.message));
    } catch (_) {
      emit(current.copyWith(isUpdating: false));
    }
  }

  /// Build full image URL from relative path returned by upload.
  static String _toFullUrl(String path) {
    if (path.startsWith('http')) return path;
    return 'https://sekka.runasp.net$path';
  }

  static ProfileModel _withImageUrl(ProfileEntity p, String path) {
    return ProfileModel(
      id: p.id, name: p.name, phone: p.phone, email: p.email,
      profileImageUrl: _toFullUrl(path),
      licenseImageUrl: p.licenseImageUrl,
      vehicleType: p.vehicleType, isOnline: p.isOnline,
      defaultRegion: p.defaultRegion, cashOnHand: p.cashOnHand,
      walletBalance: p.walletBalance, totalPoints: p.totalPoints,
      level: p.level, nextLevelPoints: p.nextLevelPoints,
      joinedAt: p.joinedAt, totalOrders: p.totalOrders,
      totalDelivered: p.totalDelivered, averageRating: p.averageRating,
      shiftStatus: p.shiftStatus, healthScore: p.healthScore,
      badgesCount: p.badgesCount, currentStreak: p.currentStreak,
      completionPercentage: p.completionPercentage,
      todayOrdersCount: p.todayOrdersCount, todayEarnings: p.todayEarnings,
      referralCode: p.referralCode,
    );
  }

  static ProfileModel _withLicenseUrl(ProfileEntity p, String path) {
    return ProfileModel(
      id: p.id, name: p.name, phone: p.phone, email: p.email,
      profileImageUrl: p.profileImageUrl,
      licenseImageUrl: _toFullUrl(path),
      vehicleType: p.vehicleType, isOnline: p.isOnline,
      defaultRegion: p.defaultRegion, cashOnHand: p.cashOnHand,
      walletBalance: p.walletBalance, totalPoints: p.totalPoints,
      level: p.level, nextLevelPoints: p.nextLevelPoints,
      joinedAt: p.joinedAt, totalOrders: p.totalOrders,
      totalDelivered: p.totalDelivered, averageRating: p.averageRating,
      shiftStatus: p.shiftStatus, healthScore: p.healthScore,
      badgesCount: p.badgesCount, currentStreak: p.currentStreak,
      completionPercentage: p.completionPercentage,
      todayOrdersCount: p.todayOrdersCount, todayEarnings: p.todayEarnings,
      referralCode: p.referralCode,
    );
  }

  // ── Hydration ──

  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        return ProfileLoaded(
          profile: ProfileModel.fromJson(
            Map<String, dynamic>.from(json['profile'] as Map),
          ),
          completion: ProfileCompletionModel.fromJson(
            Map<String, dynamic>.from(json['completion'] as Map),
          ),
          stats: ProfileStatsModel.fromJson(
            Map<String, dynamic>.from(json['stats'] as Map),
          ),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    if (state is ProfileLoaded) {
      final profile = state.profile;
      final completion = state.completion;
      final stats = state.stats;
      if (profile is ProfileModel &&
          completion is ProfileCompletionModel &&
          stats is ProfileStatsModel) {
        return {
          'type': 'loaded',
          'profile': profile.toJson(),
          'completion': completion.toJson(),
          'stats': stats.toJson(),
        };
      }
    }
    return null;
  }
}
