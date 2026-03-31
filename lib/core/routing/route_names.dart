abstract final class RouteNames {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String success = '/success';

  // Main
  static const String main = '/main';
  static const String addOrder = '/add-order';
  static const String orderDetails = '/order-details';
  static const String completeOrder = '/complete-order';
  static const String profile = '/profile';

  // Profile
  static const String editProfile = '/edit-profile';
  static const String profileStats = '/profile-stats';
  static const String emergencyContacts = '/emergency-contacts';
  static const String profileExpenses = '/profile-expenses';
  static const String settings = '/settings';

  // Financial
  static const String settlements = '/settlements';
  static const String createSettlement = '/settlements/create';
  static const String detailedStats = '/detailed-stats';
  static const String paymentRequests = '/payment-requests';
  static const String createPaymentRequest = '/payment-requests/create';
  static const String invoices = '/invoices';
  static const String invoiceDetail = '/invoices/detail';

  // Customers
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';

  // Partners
  static const String partners = '/partners';
  static const String partnerDetail = '/partner-detail';
  static const String partnerSettlementDetail = '/settlements/partner-detail';

  // Communication
  static const String notifications = '/notifications';
  static const String sos = '/sos';
  static const String sosHistory = '/sos-history';
  static const String chat = '/chat';

  // Badge
  static const String badge = '/badge';
  static const String badgeScanner = '/badge/scanner';
}
