import '../entities/consent_entity.dart';

abstract class PrivacyRepository {
  Future<List<ConsentEntity>> getConsents();
  Future<ConsentEntity> updateConsent(String type, bool isGranted);
  Future<DataRequestEntity> requestDataExport();
  Future<DataRequestEntity> requestDataDeletion(String requestType, String? reason);
  Future<DataRequestEntity> getDeleteStatus();
}
