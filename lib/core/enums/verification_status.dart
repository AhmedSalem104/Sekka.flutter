enum VerificationStatus {
  pending(0),
  verified(1),
  rejected(2),
  documentRequested(3);

  const VerificationStatus(this.value);
  final int value;

  static VerificationStatus fromValue(int v) => VerificationStatus.values
      .firstWhere((e) => e.value == v, orElse: () => pending);
}
