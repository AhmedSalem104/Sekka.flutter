import 'dart:io';

import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

final class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

final class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested(this.updates);

  final Map<String, dynamic> updates;

  @override
  List<Object?> get props => [updates];
}

final class ProfileImageUploadRequested extends ProfileEvent {
  const ProfileImageUploadRequested(this.imageFile);

  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}

final class ProfileImageDeleteRequested extends ProfileEvent {
  const ProfileImageDeleteRequested();
}

final class LicenseImageUploadRequested extends ProfileEvent {
  const LicenseImageUploadRequested(this.imageFile);

  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}
