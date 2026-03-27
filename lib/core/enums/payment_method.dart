enum PaymentMethod {
  cash(0),
  wallet(1),
  card(2),
  instaPay(3);

  const PaymentMethod(this.value);
  final int value;

  static PaymentMethod fromValue(int v) => PaymentMethod.values
      .firstWhere((e) => e.value == v, orElse: () => cash);
}
