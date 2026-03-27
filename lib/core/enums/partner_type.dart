enum PartnerType {
  restaurant(0),
  shop(1),
  pharmacy(2),
  supermarket(3),
  warehouse(4),
  eCommerce(5),
  other(6);

  const PartnerType(this.value);
  final int value;

  static PartnerType fromValue(int v) =>
      PartnerType.values.firstWhere((e) => e.value == v, orElse: () => other);
}
