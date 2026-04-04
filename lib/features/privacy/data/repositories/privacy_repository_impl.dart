import '../../domain/entities/consent_entity.dart';
import '../../domain/repositories/privacy_repository.dart';
import '../datasources/privacy_remote_datasource.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  PrivacyRepositoryImpl({required PrivacyRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final PrivacyRemoteDataSource _remote;

  @override
  Future<List<ConsentEntity>> getConsents() => _remote.getConsents();

  @override
  Future<ConsentEntity> updateConsent(String type, bool isGranted) =>
      _remote.updateConsent(type, isGranted);

  @override
  Future<DataRequestEntity> requestDataExport() => _remote.requestDataExport();

  @override
  Future<DataRequestEntity> requestDataDeletion(
    String requestType,
    String? reason,
  ) =>
      _remote.requestDataDeletion(requestType, reason);

  @override
  Future<DataRequestEntity> getDeleteStatus() => _remote.getDeleteStatus();
}
