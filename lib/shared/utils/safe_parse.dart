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
