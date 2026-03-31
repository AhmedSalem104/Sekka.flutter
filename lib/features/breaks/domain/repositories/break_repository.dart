import '../entities/break_entity.dart';
import '../entities/break_suggestion_entity.dart';

abstract interface class BreakRepository {
  Future<BreakSuggestionEntity> getSuggestion();
  Future<BreakEntity?> getActiveBreak();
  Future<BreakEntity> startBreak({
    required int energyBefore,
    required String locationDescription,
  });
  Future<BreakEntity> endBreak({required int energyAfter});
  Future<List<BreakEntity>> getHistory({int page = 1, int pageSize = 20});
}
