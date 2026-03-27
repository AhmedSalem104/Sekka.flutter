enum CommissionType {
  fixedPerOrder(0),
  percentagePerOrder(1),
  monthlyFlat(2);

  const CommissionType(this.value);
  final int value;

  static CommissionType fromValue(int v) => CommissionType.values
      .firstWhere((e) => e.value == v, orElse: () => fixedPerOrder);
}
