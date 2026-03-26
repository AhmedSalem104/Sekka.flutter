abstract final class ApiConstants {
  static const String baseUrl = 'https://sekka.runasp.net';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String acceptLanguage = 'ar';
}
