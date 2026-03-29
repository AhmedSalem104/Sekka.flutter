// Order-related enums matching the API specification.

enum OrderStatus {
  pending(0, 'في الانتظار'),
  accepted(1, 'مقبول'),
  pickedUp(2, 'تم الاستلام'),
  inTransit(3, 'في الطريق'),
  arrivedAtDestination(4, 'وصل للوجهة'),
  delivered(5, 'تم التسليم'),
  failed(6, 'فشل التسليم'),
  cancelled(7, 'ملغي'),
  partiallyDelivered(8, 'تسليم جزئي'),
  retryPending(9, 'إعادة محاولة'),
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
  wallet(2, 'محفظة إلكترونية'),
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
  customerNotAvailable(0, 'العميل غير متواجد'),
  customerRefused(1, 'العميل رفض الاستلام'),
  wrongAddress(2, 'عنوان خاطئ'),
  phoneUnreachable(3, 'الهاتف مغلق/لا يرد'),
  accessDenied(4, 'لا يمكن الوصول للمكان'),
  damagedPackage(5, 'الشحنة تالفة'),
  insufficientPayment(6, 'المبلغ غير كافي'),
  securityIssue(7, 'مشكلة أمنية'),
  weatherConditions(8, 'ظروف جوية'),
  other(9, 'أخرى');

  const DeliveryFailReason(this.value, this.arabic);
  final int value;
  final String arabic;

  static DeliveryFailReason fromValue(int value) =>
      DeliveryFailReason.values.firstWhere((e) => e.value == value, orElse: () => other);
}

enum CancellationReason {
  customerRequest(0, 'بطلب من العميل'),
  driverRequest(1, 'بطلب من السائق'),
  partnerRequest(2, 'بطلب من الشريك'),
  duplicateOrder(3, 'طلب مكرر'),
  fraudSuspicion(4, 'اشتباه احتيال'),
  systemError(5, 'خطأ في النظام'),
  outOfServiceArea(6, 'خارج نطاق الخدمة'),
  other(7, 'أخرى');

  const CancellationReason(this.value, this.arabic);
  final int value;
  final String arabic;

  static CancellationReason fromValue(int value) =>
      CancellationReason.values.firstWhere((e) => e.value == value, orElse: () => other);
}

enum PhotoType {
  proofOfDelivery(0, 'إثبات تسليم'),
  packagePhoto(1, 'صورة الشحنة'),
  damagePhoto(2, 'صورة التلف'),
  invoicePhoto(3, 'صورة الفاتورة'),
  signaturePhoto(4, 'التوقيع'),
  locationPhoto(5, 'صورة الموقع');

  const PhotoType(this.value, this.arabic);
  final int value;
  final String arabic;

  static PhotoType fromValue(int value) =>
      PhotoType.values.firstWhere((e) => e.value == value, orElse: () => proofOfDelivery);
}
