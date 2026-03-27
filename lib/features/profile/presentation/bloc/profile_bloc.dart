import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
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
    emit(const ProfileLoading());
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
      emit(ProfileError(e.message));
    } catch (_) {
      emit(const ProfileError(AppStrings.unknownError));
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
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (_) {
      emit(const ProfileError(AppStrings.unknownError));
    }
  }

  Future<void> _onUpdate(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));

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
      await _repository.uploadProfileImage(event.imageFile);
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
      await _repository.uploadLicenseImage(event.imageFile);
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
}
