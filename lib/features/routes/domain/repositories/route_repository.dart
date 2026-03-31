import '../../data/models/route_model.dart';

abstract class RouteRepository {
  Future<RouteModel> optimizeRoute({
    List<String>? orderIds,
    double? startLatitude,
    double? startLongitude,
    String? optimizationType,
  });
  Future<RouteModel?> getActiveRoute();
  Future<RouteModel> reorderRoute(String id, List<String> orderIds);
  Future<RouteModel> addOrderToRoute(String id, String orderId);
  Future<RouteModel> completeRoute(String id);
}
