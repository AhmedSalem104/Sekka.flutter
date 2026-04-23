/// Safe parsers for API fields that may arrive as int OR string
/// (backend sometimes returns enum names instead of integer values).

int safeInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

int parseVehicleType(dynamic v) {
  if (v is int) return v;
  if (v is String) {
    const map = {
      'motorcycle': 0, 'car': 1, 'van': 2, 'truck': 3, 'bicycle': 4,
    };
    return map[v.toLowerCase()] ?? 0;
  }
  return 0;
}

int parseShiftStatus(dynamic v) {
  if (v is int) return v;
  if (v is String) {
    const map = {'offshift': 0, 'onshift': 1};
    return map[v.toLowerCase()] ?? 0;
  }
  return 0;
}

int parseOrderStatus(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    // Try int parse first (e.g. "3")
    final asInt = int.tryParse(v);
    if (asInt != null) return asInt;
    // Then try enum name (e.g. "InTransit")
    const map = {
      'pending': 0,
      'accepted': 1,
      'pickedup': 2,
      'intransit': 3,
      'arrivedatdestination': 4,
      'delivered': 5,
      'failed': 6,
      'cancelled': 7,
      'partiallydelivered': 8,
      'retrypending': 9,
      'returned': 10,
    };
    return map[v.toLowerCase()] ?? 0;
  }
  return 0;
}

int parsePaymentMethod(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final asInt = int.tryParse(v);
    if (asInt != null) return asInt;
    const map = {
      'cash': 0,
      'visa': 1,
      'wallet': 2,
    };
    return map[v.toLowerCase()] ?? 0;
  }
  return 0;
}

int parseOrderPriority(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final asInt = int.tryParse(v);
    if (asInt != null) return asInt;
    const map = {
      'normal': 0,
      'high': 1,
      'urgent': 2,
    };
    return map[v.toLowerCase()] ?? 0;
  }
  return 0;
}

/// Generic safe enum parser — tries int first, then looks up string in [map].
int safeEnum(dynamic v, Map<String, int> map, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final asInt = int.tryParse(v);
    if (asInt != null) return asInt;
    return map[v.toLowerCase()] ?? fallback;
  }
  return fallback;
}

int parseSettlementType(dynamic v) => safeEnum(v, {
      'cash': 0,
      'banktransfer': 1,
      'wallet': 2,
    });

int parsePartnerType(dynamic v) => safeEnum(v, {
      'restaurant': 0,
      'store': 1,
      'pharmacy': 2,
      'other': 3,
    });

int parseCommissionType(dynamic v) => safeEnum(v, {
      'fixed': 0,
      'percentage': 1,
    });

int parseVerificationStatus(dynamic v) => safeEnum(v, {
      'unverified': 0,
      'pending': 1,
      'verified': 2,
      'rejected': 3,
    });

int parseChatType(dynamic v) => safeEnum(v, {
      'private': 0,
      'group': 1,
      'support': 2,
      'system': 3,
    }, 3);

int parseChatStatus(dynamic v) => safeEnum(v, {
      'active': 0,
      'closed': 1,
      'archived': 2,
    });

int parseInvoiceStatus(dynamic v) => safeEnum(v, {
      'draft': 0,
      'sent': 1,
      'paid': 2,
      'overdue': 3,
      'cancelled': 4,
    });

int parsePaymentStatus(dynamic v) => safeEnum(v, {
      'pending': 0,
      'approved': 1,
      'rejected': 2,
      'completed': 3,
    });

int parseReferralStatus(dynamic v) => safeEnum(v, {
      'pending': 0,
      'active': 1,
      'expired': 2,
    });

int parseRouteStatus(dynamic v) => safeEnum(v, {
      'planned': 0,
      'active': 1,
      'completed': 2,
      'cancelled': 3,
    });
