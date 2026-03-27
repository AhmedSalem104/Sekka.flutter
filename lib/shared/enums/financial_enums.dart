/// Transaction types for wallet history.
enum TransactionType {
  orderEarning,    // 0 — ربح من طلب
  commission,      // 1 — عمولة
  tip,             // 2 — بقشيش
  settlement,      // 3 — تسوية
  bonus,           // 4 — مكافأة
  fine,            // 5 — غرامة
  refund,          // 6 — استرداد
  subscriptionFee, // 7 — رسوم اشتراك
  adjustment,      // 8 — تعديل
  expense,         // 9 — مصروف
}

/// Settlement methods.
enum SettlementType {
  cashToPartner,  // 0 — نقدي للشريك
  bankTransfer,   // 1 — تحويل بنكي
  vodafoneCash,   // 2 — فودافون كاش
  instapay,       // 3 — انستاباي
  fawry,          // 4 — فوري
}

/// Manual payment methods for subscription plans.
enum ManualPaymentMethod {
  vodafoneCash,   // 0 — فودافون كاش
  instapay,       // 1 — انستاباي
  fawry,          // 2 — فوري
  bankTransfer,   // 3 — تحويل بنكي
}

/// Payment request statuses.
enum PaymentRequestStatus {
  pending,        // 0 — قيد الانتظار
  underReview,    // 1 — قيد المراجعة
  approved,       // 2 — مقبول
  rejected,       // 3 — مرفوض
  cancelled,      // 4 — ملغي
}

/// Invoice statuses.
enum InvoiceStatus {
  pending,        // 0 — معلقة
  paid,           // 1 — مدفوعة
  overdue,        // 2 — متأخرة
  voided,         // 3 — ملغاة
}
