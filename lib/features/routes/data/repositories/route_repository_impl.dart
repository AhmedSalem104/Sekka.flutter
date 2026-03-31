import '../../domain/repositories/route_repository.dart';
import '../datasources/route_remote_datasource.dart';
import '../models/route_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final RouteRemoteDataSource _remote;

  @override
  Future<RouteModel> optimizeRoute({
    List<String>? orderIds,
    double? startLatitude,
    double? startLongitude,
    String? optimizationType,
  }) =>
      _remote.optimizeRoute(
        orderIds: orderIds,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        optimizationType: optimizationType,
      );

  @override
  Future<RouteModel?> getActiveRoute() => _remote.getActiveRoute();

  @override
  Future<RouteModel> reorderRoute(String id, List<String> orderIds) =>
      _remote.reorderRoute(id, orderIds);

  @override
  Future<RouteModel> addOrderToRoute(String id, String orderId) =>
      _remote.addOrderToRoute(id, orderId);

  @override
  Future<RouteModel> completeRoute(String id) => _remote.completeRoute(id);
}
