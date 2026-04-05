import 'package:equatable/equatable.dart';

class VersionCheckModel extends Equatable {
  const VersionCheckModel({
    required this.isUpToDate,
    required this.isForceUpdate,
    this.latestVersion,
    this.updateUrl,
    this.message,
  });

  final bool isUpToDate;
  final bool isForceUpdate;
  final String? latestVersion;
  final String? updateUrl;
  final String? message;

  factory VersionCheckModel.fromJson(Map<String, dynamic> json) {
    return VersionCheckModel(
      isUpToDate: json['isUpToDate'] as bool? ?? true,
      isForceUpdate: json['isForceUpdate'] as bool? ?? false,
      latestVersion: json['latestVersion'] as String?,
      updateUrl: json['updateUrl'] as String?,
      message: json['message'] as String?,
    );
  }

  @override
  List<Object?> get props => [isUpToDate, isForceUpdate, latestVersion];
}
