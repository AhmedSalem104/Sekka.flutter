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

  // Wallet endpoints
  static const String _wallet = '$baseUrl/wallet';
  static const String walletBalance = '$_wallet/balance';
  static const String walletTransactions = '$_wallet/transactions';
  static const String walletSummary = '$_wallet/summary';
  static const String walletCashStatus = '$_wallet/cash-status';

  // Settlement endpoints
  static const String settlements = '$baseUrl/settlements';
  static const String settlementDailySummary = '$settlements/daily-summary';
  static String settlementPartnerBalance(String partnerId) =>
      '$settlements/partner-balance/$partnerId';
  static String settlementReceipt(String id) => '$settlements/$id/receipt';

  // Statistics endpoints
  static const String _statistics = '$baseUrl/statistics';
  static const String statisticsDaily = '$_statistics/daily';
  static const String statisticsWeekly = '$_statistics/weekly';
  static const String statisticsMonthly = '$_statistics/monthly';
  static const String statisticsHeatmap = '$_statistics/heatmap';
  static const String statisticsExport = '$_statistics/export';

  // Payment Request endpoints
  static const String paymentRequests = '$baseUrl/payment-requests';
  static String paymentRequestDetail(String id) => '$paymentRequests/$id';
  static String paymentRequestProof(String id) =>
      '$paymentRequests/$id/upload-proof';

  // Invoice endpoints
  static const String invoices = '$baseUrl/invoices';
  static const String invoicesSummary = '$invoices/summary';
  static String invoiceDetail(String id) => '$invoices/$id';
  static String invoicePdf(String id) => '$invoices/$id/pdf';

  // Profile endpoints
  static const String _profile = '$baseUrl/profile';
  static const String profile = _profile;
  static const String profileImage = '$_profile/image';
  static const String profileLicenseImage = '$_profile/license-image';
  static const String profileCompletion = '$_profile/completion';
  static const String profileStats = '$_profile/stats';
  static const String profileBadges = '$_profile/badges';
  static const String profileActivityLog = '$_profile/activity-log';
  static const String profileEmergencyContacts = '$_profile/emergency-contacts';
  static String profileEmergencyContact(String id) =>
      '$_profile/emergency-contacts/$id';
  static const String profileSubscription = '$_profile/subscription';
  static const String profileSubscriptionUpgrade =
      '$_profile/subscription/upgrade';
  static const String profileAchievements = '$_profile/achievements';
  static const String profileChallenges = '$_profile/challenges';
  static const String profileLeaderboard = '$_profile/leaderboard';
  static const String profileExpenses = '$_profile/expenses';

  // Settings endpoints
  static const String _settings = '$baseUrl/settings';
  static const String settings = _settings;
  static const String settingsFocusMode = '$_settings/focus-mode';
  static const String settingsQuietHours = '$_settings/quiet-hours';
  static const String settingsNotifications = '$_settings/notifications';
  static const String settingsCostParams = '$_settings/cost-params';
  static const String settingsHomeLocation = '$_settings/home-location';
  static const String settingsNotificationChannels =
      '$_settings/notification-channels';
  static String settingsNotificationChannel(String type) =>
      '$_settings/notification-channels/$type';
  static const String settingsNotificationChannelsBulk =
      '$_settings/notification-channels/bulk';

  // Analytics endpoints
  static const String _analytics = '$baseUrl/analytics';
  static const String analyticsSourceBreakdown = '$_analytics/source-breakdown';
  static const String analyticsCustomerProfitability =
      '$_analytics/customer-profitability';
  static const String analyticsRegionAnalysis = '$_analytics/region-analysis';
  static const String analyticsTimeAnalysis = '$_analytics/time-analysis';
  static const String analyticsCancellationReport =
      '$_analytics/cancellation-report';
  static const String analyticsProfitabilityTrends =
      '$_analytics/profitability-trends';

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
