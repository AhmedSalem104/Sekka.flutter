enum ContactType {
  customer(0),
  partner(1),
  driver(2),
  other(3);

  const ContactType(this.value);
  final int value;

  static ContactType fromValue(int v) =>
      ContactType.values.firstWhere((e) => e.value == v, orElse: () => other);
}
