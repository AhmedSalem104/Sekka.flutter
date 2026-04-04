import 'dart:io';

import '../../../../shared/network/paginated_response.dart';
import '../entities/emergency_contact_entity.dart';
import '../entities/expense_entity.dart';
import '../entities/health_score_entity.dart';
import '../entities/leaderboard_entity.dart';
import '../entities/profile_completion_entity.dart';
import '../entities/profile_entity.dart';
import '../entities/profile_stats_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<HealthScoreEntity> getHealthScore();

  Future<ProfileCompletionEntity> getCompletion();

  Future<ProfileStatsEntity> getStats();

  Future<LeaderboardEntity> getLeaderboard();

  Future<List<EmergencyContactEntity>> getEmergencyContacts();

  Future<PaginatedResponse<ExpenseEntity>> getExpenses({
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<ProfileEntity> updateProfile(Map<String, dynamic> updates);

  Future<String> uploadProfileImage(File imageFile);

  Future<void> deleteProfileImage();

  Future<String> uploadLicenseImage(File imageFile);

  Future<EmergencyContactEntity> addEmergencyContact(
    Map<String, dynamic> data,
  );

  Future<void> deleteEmergencyContact(String id);

  Future<void> addExpense(Map<String, dynamic> data);
}
