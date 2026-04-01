import '../../data/models/parking_model.dart';

abstract class ParkingRepository {
  Future<List<ParkingModel>> getAll();

  Future<ParkingModel> create({
    required double latitude,
    required double longitude,
    String? address,
    int qualityRating = 3,
    bool isPaid = false,
  });

  Future<ParkingModel> update(String id, ParkingModel model);

  Future<void> delete(String id);

  Future<List<ParkingModel>> getNearby({
    required double latitude,
    required double longitude,
  });
}
