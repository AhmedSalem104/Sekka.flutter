import '../../domain/repositories/parking_repository.dart';
import '../datasources/parking_remote_datasource.dart';
import '../models/parking_model.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  const ParkingRepositoryImpl({required this.remoteDataSource});

  final ParkingRemoteDataSource remoteDataSource;

  @override
  Future<List<ParkingModel>> getAll() => remoteDataSource.getAll();

  @override
  Future<ParkingModel> create({
    required double latitude,
    required double longitude,
    String? address,
    int qualityRating = 3,
    bool isPaid = false,
  }) =>
      remoteDataSource.create(
        latitude: latitude,
        longitude: longitude,
        address: address,
        qualityRating: qualityRating,
        isPaid: isPaid,
      );

  @override
  Future<ParkingModel> update(String id, ParkingModel model) =>
      remoteDataSource.update(id, model);

  @override
  Future<void> delete(String id) => remoteDataSource.delete(id);

  @override
  Future<List<ParkingModel>> getNearby({
    required double latitude,
    required double longitude,
  }) =>
      remoteDataSource.getNearby(
        latitude: latitude,
        longitude: longitude,
      );
}
