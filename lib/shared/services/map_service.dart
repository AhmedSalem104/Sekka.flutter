import 'package:dio/dio.dart';

import '../network/api_constants.dart';

/// Result of a geocoding query (address → coordinates).
class GeocodeResult {
  const GeocodeResult({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.city,
    this.confidence,
  });

  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final String? city;
  final double? confidence;

  factory GeocodeResult.fromJson(Map<String, dynamic> json) => GeocodeResult(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        formattedAddress: json['formattedAddress'] as String?,
        city: json['city'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
      );
}

/// Result of a reverse-geocoding query (coordinates → address).
class ReverseGeocodeResult {
  const ReverseGeocodeResult({
    required this.address,
    this.city,
    this.country,
  });

  final String address;
  final String? city;
  final String? country;

  factory ReverseGeocodeResult.fromJson(Map<String, dynamic> json) =>
      ReverseGeocodeResult(
        address: json['address'] as String? ?? '',
        city: json['city'] as String?,
        country: json['country'] as String?,
      );
}

/// Result of a distance query between two points.
class DistanceResult {
  const DistanceResult({
    required this.distanceKm,
    required this.durationMinutes,
  });

  final double distanceKm;
  final double durationMinutes;

  factory DistanceResult.fromJson(Map<String, dynamic> json) => DistanceResult(
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 0,
      );
}

/// Navigation deep links for a single destination.
class NavigationLinks {
  const NavigationLinks({
    required this.googleMapsUrl,
    required this.wazeUrl,
  });

  final String googleMapsUrl;
  final String wazeUrl;

  factory NavigationLinks.fromJson(Map<String, dynamic> json) =>
      NavigationLinks(
        googleMapsUrl: json['googleMapsUrl'] as String? ?? '',
        wazeUrl: json['wazeUrl'] as String? ?? '',
      );
}

/// Navigation deep links for a multi-stop route.
/// Waze doesn't natively support multiple waypoints, so the backend
/// returns the first stop URL plus a per-stop list as a fallback.
class MultiStopNavigationLinks {
  const MultiStopNavigationLinks({
    required this.googleMapsUrl,
    required this.wazeFirstStopUrl,
    required this.wazePerStopUrls,
  });

  final String googleMapsUrl;
  final String wazeFirstStopUrl;
  final List<String> wazePerStopUrls;

  factory MultiStopNavigationLinks.fromJson(Map<String, dynamic> json) =>
      MultiStopNavigationLinks(
        googleMapsUrl: json['googleMapsUrl'] as String? ?? '',
        wazeFirstStopUrl: json['wazeFirstStopUrl'] as String? ?? '',
        wazePerStopUrls: (json['wazePerStopUrls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}

/// A single stop for multi-stop navigation.
class NavigationStop {
  const NavigationStop({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;
  final String? label;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (label != null) 'label': label,
      };
}

/// Service for all backend Map operations:
/// geocoding, reverse-geocoding, distance, and navigation links.
///
/// Used by the map picker, order detail, and any feature that needs
/// address/coordinate conversions or external navigation links.
class MapService {
  const MapService(this._dio);

  final Dio _dio;

  /// GET /map/geocode — convert address text to coordinates.
  /// Backend returns a list of matches; we return the first one.
  Future<GeocodeResult?> geocode({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.mapGeocode,
        queryParameters: {
          'address': address,
          if (latitude != null) 'lat': latitude,
          if (longitude != null) 'lng': longitude,
        },
      );
      final body = response.data;
      if (body == null || body['isSuccess'] != true) return null;
      final data = body['data'];
      if (data is! List || data.isEmpty) return null;
      final first = data.first;
      if (first is! Map<String, dynamic>) return null;
      return GeocodeResult.fromJson(first);
    } on DioException {
      return null;
    }
  }

  /// GET /map/geocode — same as [geocode] but returns all matches.
  Future<List<GeocodeResult>> geocodeAll({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.mapGeocode,
        queryParameters: {
          'address': address,
          if (latitude != null) 'lat': latitude,
          if (longitude != null) 'lng': longitude,
        },
      );
      final body = response.data;
      if (body == null || body['isSuccess'] != true) return const [];
      final data = body['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(GeocodeResult.fromJson)
          .toList();
    } on DioException {
      return const [];
    }
  }

  /// GET /map/reverse-geocode — convert coordinates to address text.
  Future<ReverseGeocodeResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.mapReverseGeocode,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
        },
      );
      final body = response.data;
      if (body == null || body['isSuccess'] != true) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      return ReverseGeocodeResult.fromJson(data);
    } on DioException {
      return null;
    }
  }

  /// GET /map/distance — real road distance between two points.
  Future<DistanceResult?> getDistance({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.mapDistance,
        queryParameters: {
          'fromLat': fromLatitude,
          'fromLng': fromLongitude,
          'toLat': toLatitude,
          'toLng': toLongitude,
        },
      );
      final body = response.data;
      if (body == null || body['isSuccess'] != true) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      return DistanceResult.fromJson(data);
    } on DioException {
      return null;
    }
  }

  /// GET /map/navigate — Google Maps + Waze deep links for one destination.
  Future<NavigationLinks?> getNavigationLinks({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.mapNavigate,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          if (label != null) 'label': label,
        },
      );
      final body = response.data;
      if (body == null || body['isSuccess'] != true) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      return NavigationLinks.fromJson(data);
    } on DioException {
      return null;
    }
  }

  /// POST /map/navigate/multi-stop — deep links for an optimized
  /// multi-stop route. Waze can't take multiple waypoints, so the
  /// backend returns one Google Maps link plus per-stop Waze links.
  Future<MultiStopNavigationLinks?> getMultiStopNavigation({
    required List<NavigationStop> stops,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.mapNavigateMultiStop,
        data: {
          'stops': stops.map((s) => s.toJson()).toList(),
        },
      );
      final body = response.data;
      if (body == null || body['isSuccess'] != true) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      return MultiStopNavigationLinks.fromJson(data);
    } on DioException {
      return null;
    }
  }
}
