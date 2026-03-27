abstract final class ApiConstants {
  static const String baseUrl = 'https://sekka.runasp.net/api/v1';

  // Auth endpoints
  static const String _auth = '$baseUrl/auth';
  static const String vehicleTypes = '$_auth/vehicle-types';
  static const String sendVerification = '$_auth/send-verification';
  static const String register = '$_auth/register';
  static const String login = '$_auth/login';
  static const String forgotPassword = '$_auth/forgot-password';
  static const String resetPassword = '$_auth/reset-password';
  static const String changePassword = '$_auth/change-password';
  static const String refreshToken = '$_auth/refresh-token';
  static const String logout = '$_auth/logout';
  static const String registerDevice = '$_auth/register-device';
  static const String sessions = '$_auth/sessions';
  static const String logoutAll = '$_auth/logout-all';
  static const String deleteAccount = '$_auth/account';
  static const String confirmDeletion = '$_auth/account/confirm-deletion';

  /// Endpoints that don't require authentication.
  static const publicEndpoints = [
    vehicleTypes,
    sendVerification,
    register,
    login,
    forgotPassword,
    resetPassword,
    refreshToken,
  ];

  static bool isPublic(String url) =>
      publicEndpoints.any((endpoint) => url.startsWith(endpoint));
}
