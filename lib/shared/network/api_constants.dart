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

  // App Config endpoints
  static const String _config = '$baseUrl/config';
  static const String configCheckVersion = '$_config/check-version';
  static const String configNotices = '$_config/notices';
  static const String configFeatures = '$_config/features';

  // Demo endpoints
  static const String demoStart = '$baseUrl/demo/start';
  static const String demoData = '$baseUrl/demo/data';
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
      '$settlements/partner/$partnerId/balance';
  static String settlementReceipt(String id) => '$settlements/$id/receipt';

  // Partner endpoints
  static const String partners = '$baseUrl/partners';
  static String partnerDetail(String id) => '$partners/$id';
  static String partnerOrders(String id) => '$partners/$id/orders';
  static String partnerPickupPoints(String id) => '$partners/$id/pickup-points';
  static String partnerVerification(String id) => '$partners/$id/verification';

  // Statistics endpoints
  static const String _statistics = '$baseUrl/statistics';
  static const String statisticsDaily = '$_statistics/daily';
  static const String statisticsWeekly = '$_statistics/weekly';
  static const String statisticsMonthly = '$_statistics/monthly';
  static const String statisticsHeatmap = '$_statistics/heatmap';
  static const String statisticsToday = '$_statistics/today';
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

  // Privacy endpoints
  static const String _privacy = '$baseUrl/privacy';
  static const String privacyConsents = '$_privacy/consents';
  static String privacyConsent(String type) => '$_privacy/consents/$type';
  static const String privacyExportData = '$_privacy/export-data';
  static const String privacyDeleteData = '$_privacy/delete-data';
  static const String privacyDeleteDataStatus = '$_privacy/delete-data/status';

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

  // CustomerInsights endpoints
  static const String _customerInsights = '$baseUrl/customer-insights';
  static String customerInsightsProfile(String id) =>
      '$_customerInsights/$id/profile';
  static String customerInsightsInterests(String id) =>
      '$_customerInsights/$id/interests';
  static String customerInsightsRecommendations(String id) =>
      '$_customerInsights/$id/recommendations';
  static String customerInsightsRecommendationRead(String id) =>
      '$_customerInsights/recommendations/$id/read';
  static String customerInsightsRecommendationDismiss(String id) =>
      '$_customerInsights/recommendations/$id/dismiss';
  static String customerInsightsRecommendationAct(String id) =>
      '$_customerInsights/recommendations/$id/act';
  static String customerInsightsBehavior(String id) =>
      '$_customerInsights/$id/behavior';
  static const String customerInsightsTopInterests =
      '$_customerInsights/top-interests';
  static const String customerInsightsSegments = '$_customerInsights/segments';
  static String customerInsightsSegmentCustomers(String segmentId) =>
      '$_customerInsights/segments/$segmentId/customers';

  // Chat endpoints
  static const String _chat = '$baseUrl/chat';
  static const String chatConversations = '$_chat/conversations';
  static String chatMessages(String id) => '$_chat/conversations/$id/messages';
  static String chatClose(String id) => '$_chat/conversations/$id/close';
  static String chatMessageRead(String id) => '$_chat/messages/$id/read';
  static const String chatUnreadCount = '$_chat/unread-count';

  // Badge endpoints
  static const String _badge = '$baseUrl/badge';
  static const String badge = _badge;
  static String badgeVerify(String qrToken) => '$_badge/verify/$qrToken';

  // Search endpoint
  static const String search = '$baseUrl/search';

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

  // Map endpoints
  static const String _map = '$baseUrl/map';
  static const String mapGeocode = '$_map/geocode';
  static const String mapReverseGeocode = '$_map/reverse-geocode';
  static const String mapDistance = '$_map/distance';
  static const String mapNavigate = '$_map/navigate';
  static const String mapNavigateMultiStop = '$_map/navigate/multi-stop';

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

  // Shift endpoints
  static const String _shifts = '$baseUrl/shifts';
  static const String shiftStart = '$_shifts/start';
  static const String shiftEnd = '$_shifts/end';
  static const String shiftCurrent = '$_shifts/current';
  static const String shiftSummary = '$_shifts/summary';

  // Break endpoints
  static const String _breaks = '$baseUrl/breaks';
  static const String breakSuggestion = '$_breaks/suggestion';
  static const String breakActive = '$_breaks/active';
  static const String breakStart = '$_breaks/start';
  static const String breakEnd = '$_breaks/end';
  static const String breakHistory = '$_breaks/history';

  // OCR endpoints
  static const String _ocr = '$baseUrl/ocr';
  static const String ocrScanInvoice = '$_ocr/scan-invoice';
  static const String ocrScanToOrder = '$_ocr/scan-to-order';
  static const String ocrScanBatch = '$_ocr/scan-batch';

  // Health Score endpoints
  static const String _healthScore = '$baseUrl/health-score';
  static const String healthScore = _healthScore;
  static const String healthScoreTips = '$_healthScore/tips';

  // Colleague Radar endpoints
  static const String _colleagueRadar = '$baseUrl/colleague-radar';
  static const String colleagueRadarNearby = '$_colleagueRadar/nearby';
  static const String colleagueRadarHelpRequests =
      '$_colleagueRadar/help-requests';
  static const String colleagueRadarHelpRequestsNearby =
      '$_colleagueRadar/help-requests/nearby';
  static const String colleagueRadarMyRequests =
      '$_colleagueRadar/help-requests/my';
  static String colleagueRadarRespond(String id) =>
      '$_colleagueRadar/help-requests/$id/respond';
  static String colleagueRadarResolve(String id) =>
      '$_colleagueRadar/help-requests/$id/resolve';
  static const String colleagueRadarLocation = '$_colleagueRadar/location';

  // Gamification endpoints
  static const String _gamification = '$baseUrl/gamification';
  static const String gamificationChallenges = '$_gamification/challenges';
  static const String gamificationAchievements = '$_gamification/achievements';
  static const String gamificationLeaderboard = '$_gamification/leaderboard';
  static String gamificationClaimChallenge(String challengeId) =>
      '$_gamification/challenges/$challengeId/claim';
  static const String gamificationPointsHistory = '$_gamification/points/history';
  static const String gamificationPointsTotal = '$_gamification/points/total';
  static const String gamificationLevel = '$_gamification/level';

  // Sync endpoints
  static const String _sync = '$baseUrl/sync';
  static const String syncPush = '$_sync/push';
  static const String syncPull = '$_sync/pull';
  static const String syncResolveConflict = '$_sync/resolve-conflict';
  static const String syncStatus = '$_sync/status';

  // Parking endpoints
  static const String _parking = '$baseUrl/parking';
  static const String parking = _parking;
  static String parkingDetail(String id) => '$_parking/$id';
  static const String parkingNearby = '$_parking/nearby';

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
    demoStart,
    configCheckVersion,
  ];

  static bool isPublic(String url) =>
      publicEndpoints.any((endpoint) => url.startsWith(endpoint));
}
