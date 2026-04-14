import 'dart:io';

import '../../../../shared/network/paginated_response.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/health_score_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/entities/profile_completion_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_stats_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final ProfileRemoteDataSource _remote;

  @override
  Future<ProfileEntity> getProfile() => _remote.getProfile();

  @override
  Future<ProfileCompletionEntity> getCompletion() => _remote.getCompletion();

  @override
  Future<ProfileStatsEntity> getStats() => _remote.getStats();

  @override
  Future<HealthScoreEntity> getHealthScore() => _remote.getHealthScore();

  @override
  Future<LeaderboardEntity> getLeaderboard() => _remote.getLeaderboard();

  @override
  Future<PaginatedResponse<ExpenseEntity>> getExpenses({
    int pageNumber = 1,
    int pageSize = 20,
  }) =>
      _remote.getExpenses(pageNumber: pageNumber, pageSize: pageSize);

  @override
  Future<ProfileEntity> updateProfile(Map<String, dynamic> updates) =>
      _remote.updateProfile(updates);

  @override
  Future<String> uploadProfileImage(File imageFile) =>
      _remote.uploadProfileImage(imageFile);

  @override
  Future<void> deleteProfileImage() => _remote.deleteProfileImage();

  @override
  Future<String> uploadLicenseImage(File imageFile) =>
      _remote.uploadLicenseImage(imageFile);

  @override
  Future<void> addExpense(Map<String, dynamic> data) =>
      _remote.addExpense(data);
}
