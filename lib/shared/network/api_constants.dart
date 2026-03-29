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

  // Notification endpoints
  static const String _notifications = '$baseUrl/notifications';
  static const String notifications = _notifications;
  static String notificationRead(String id) => '$_notifications/$id/read';
  static const String notificationsReadAll = '$_notifications/read-all';
  static const String notificationsUnreadCount = '$_notifications/unread-count';

  // Customer endpoints
  static const String _customers = '$baseUrl/customers';
  static const String customers = _customers;
  static String customerDetail(String id) => '$_customers/$id';
  static String customerByPhone(String phone) => '$_customers/by-phone/$phone';
  static String customerRate(String id) => '$_customers/$id/rate';
  static String customerBlock(String id) => '$_customers/$id/block';
  static String customerUnblock(String id) => '$_customers/$id/unblock';
  static String customerOrders(String id) => '$_customers/$id/orders';
  static String customerInterests(String id) => '$_customers/$id/interests';
  static String customerEngagement(String id) => '$_customers/$id/engagement';

  // Chat endpoints
  static const String _chat = '$baseUrl/chat';
  static const String chatConversations = '$_chat/conversations';
  static String chatMessages(String id) => '$_chat/conversations/$id/messages';
  static String chatClose(String id) => '$_chat/conversations/$id/close';
  static String chatMessageRead(String id) => '$_chat/messages/$id/read';
  static const String chatUnreadCount = '$_chat/unread-count';

  // SOS endpoints
  static const String _sos = '$baseUrl/sos';
  static const String sosActivate = '$_sos/activate';
  static String sosDismiss(String id) => '$_sos/$id/dismiss';
  static String sosResolve(String id) => '$_sos/$id/resolve';
  static const String sosHistory = '$_sos/history';

  // Order endpoints
  static const String _orders = '$baseUrl/orders';
  static const String orders = _orders;
  static String orderDetail(String id) => '$_orders/$id';
  static String orderStatus(String id) => '$_orders/$id/status';
  static String orderDeliver(String id) => '$_orders/$id/deliver';
  static String orderFail(String id) => '$_orders/$id/fail';
  static String orderCancel(String id) => '$_orders/$id/cancel';
  static String orderTransfer(String id) => '$_orders/$id/transfer';
  static String orderPartial(String id) => '$_orders/$id/partial';
  static const String ordersBulk = '$_orders/bulk';
  static const String ordersCheckDuplicate = '$_orders/check-duplicate';
  static String orderWorth(String id) => '$_orders/$id/worth';
  static String orderPhotos(String id) => '$_orders/$id/photos';
  static String orderSwapAddress(String id) => '$_orders/$id/swap-address';
  static String orderWaitingStart(String id) => '$_orders/$id/waiting/start';
  static String orderWaitingStop(String id) => '$_orders/$id/waiting/stop';
  static const String ordersCalculatePrice = '$_orders/calculate-price';
  static String orderDisclaimer(String id) => '$_orders/$id/disclaimer';
  static String orderDispute(String id) => '$_orders/$id/dispute';
  static String orderDisputes(String id) => '$_orders/$id/disputes';
  static String orderRefund(String id) => '$_orders/$id/refund';
  static String orderRefunds(String id) => '$_orders/$id/refunds';
  static const String ordersTimeSlots = '$_orders/time-slots';
  static String orderBookSlot(String id) => '$_orders/$id/book-slot';

  // Route endpoints
  static const String _routes = '$baseUrl/routes';
  static const String routesOptimize = '$_routes/optimize';
  static const String routesActive = '$_routes/active';
  static String routeReorder(String id) => '$_routes/$id/reorder';
  static String routeAddOrder(String id) => '$_routes/$id/add-order';
  static String routeComplete(String id) => '$_routes/$id/complete';

  // Recurring Order endpoints
  static const String ordersRecurring = '$_orders/recurring';
  static String recurringOrderDetail(String id) => '$_orders/recurring/$id';
  static String recurringOrderPause(String id) => '$_orders/recurring/$id/pause';
  static String recurringOrderResume(String id) => '$_orders/recurring/$id/resume';

  // Timeline endpoints
  static const String _timeline = '$baseUrl/timeline';
  static const String timelineDaily = '$_timeline/daily';
  static const String timelineRange = '$_timeline/range';
  static const String timelineDailyFilter = '$_timeline/daily/filter';

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
