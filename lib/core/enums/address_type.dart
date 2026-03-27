enum AddressType {
  home(0),
  work(1),
  shop(2),
  restaurant(3),
  warehouse(4),
  other(5);

  const AddressType(this.value);
  final int value;

  static AddressType fromValue(int v) =>
      AddressType.values.firstWhere((e) => e.value == v, orElse: () => other);
}
