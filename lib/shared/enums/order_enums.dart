// Order-related enums matching the API specification.

enum OrderType {
  normal,
  recurring,
}

enum OrderStatus {
  pending(0, 'مستني'),
  accepted(1, 'اتقبل'),
  pickedUp(2, 'استلمت الشحنة'),
  inTransit(3, 'في السكة'),
  arrivedAtDestination(4, 'وصلت'),
  delivered(5, 'اتسلّم'),
  failed(6, 'معرفتش أسلّم'),
  cancelled(7, 'ملغي'),
  partiallyDelivered(8, 'تسليم جزئي'),
  retryPending(9, 'هجرب تاني'),
  returned(10, 'مرتجع');

  const OrderStatus(this.value, this.arabic);
  final int value;
  final String arabic;

  static OrderStatus fromValue(int value) =>
      OrderStatus.values.firstWhere((e) => e.value == value, orElse: () => pending);

  bool get isActive => switch (this) {
        pending || accepted || pickedUp || inTransit || arrivedAtDestination || retryPending => true,
        _ => false,
      };

  bool get isTerminal => switch (this) {
        delivered || failed || cancelled || returned => true,
        _ => false,
      };

  bool get canEdit => this == pending || this == accepted;
  bool get canCancel => this != delivered;
  bool get canDeliver => this == inTransit || this == arrivedAtDestination;
  bool get canFail => this == inTransit || this == arrivedAtDestination;
}

enum PaymentMethod {
  cash(0, 'كاش'),
  visa(1, 'فيزا'),
  wallet(2, 'محفظة'),
  partnerCredit(3, 'حساب الشريك');

  const PaymentMethod(this.value, this.arabic);
  final int value;
  final String arabic;

  static PaymentMethod fromValue(int value) =>
      PaymentMethod.values.firstWhere((e) => e.value == value, orElse: () => cash);
}

enum OrderPriority {
  normal(0, 'عادي'),
  urgent(1, 'عاجل'),
  vip(2, 'مميز');

  const OrderPriority(this.value, this.arabic);
  final int value;
  final String arabic;

  static OrderPriority fromValue(int value) =>
      OrderPriority.values.firstWhere((e) => e.value == value, orElse: () => normal);
}

enum DeliveryFailReason {
  customerNotAvailable(0, 'العميل مش موجود'),
  customerRefused(1, 'العميل رفض يستلم'),
  wrongAddress(2, 'العنوان غلط'),
  phoneUnreachable(3, 'التليفون مقفول أو مبيردش'),
  accessDenied(4, 'مقدرتش أوصل للمكان'),
  damagedPackage(5, 'الشحنة باظت'),
  insufficientPayment(6, 'الفلوس مش كفاية'),
  securityIssue(7, 'مشكلة أمنية'),
  weatherConditions(8, 'الجو وحش'),
  other(9, 'حاجة تانية');

  const DeliveryFailReason(this.value, this.arabic);
  final int value;
  final String arabic;

  static DeliveryFailReason fromValue(int value) =>
      DeliveryFailReason.values.firstWhere((e) => e.value == value, orElse: () => other);
}

enum CancellationReason {
  customerRequest(0, 'العميل طلب كده'),
  driverRequest(1, 'أنا اللي لغيته'),
  partnerRequest(2, 'الشريك طلب كده'),
  duplicateOrder(3, 'طلب مكرر'),
  fraudSuspicion(4, 'حاسس إنه نصب'),
  systemError(5, 'مشكلة في السيستم'),
  outOfServiceArea(6, 'برا نطاق الخدمة'),
  other(7, 'حاجة تانية');

  const CancellationReason(this.value, this.arabic);
  final int value;
  final String arabic;

  static CancellationReason fromValue(int value) =>
      CancellationReason.values.firstWhere((e) => e.value == value, orElse: () => other);
}

enum PhotoType {
  proofOfDelivery(0, 'إثبات التسليم'),
  packagePhoto(1, 'صورة الشحنة'),
  damagePhoto(2, 'صورة التلف'),
  invoicePhoto(3, 'صورة الفاتورة'),
  signaturePhoto(4, 'التوقيع'),
  locationPhoto(5, 'صورة المكان');

  const PhotoType(this.value, this.arabic);
  final int value;
  final String arabic;

  static PhotoType fromValue(int value) =>
      PhotoType.values.firstWhere((e) => e.value == value, orElse: () => proofOfDelivery);
}
