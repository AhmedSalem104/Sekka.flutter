class FeatureFlagsModel {
  const FeatureFlagsModel({required this.features});

  final Map<String, bool> features;

  factory FeatureFlagsModel.fromJson(Map<String, dynamic> json) {
    final raw = json['features'] as Map<String, dynamic>? ?? {};
    return FeatureFlagsModel(
      features: raw.map((k, v) => MapEntry(k, v as bool? ?? false)),
    );
  }

  bool isEnabled(String key) => features[key] ?? true;

  /// Known feature keys
  static const String gamification = 'gamification';
  static const String colleagueRadar = 'colleague_radar';
  static const String ocrScan = 'ocr_scan';
  static const String voiceEntry = 'voice_entry';
  static const String callerIdLookup = 'caller_id_lookup';
  static const String demoMode = 'demo_mode';
}
