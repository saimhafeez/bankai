enum CardType {
  otherBrand,
  mastercard,
  visa,
  rupay,
  americanExpress,
  unionpay,
  discover,
  elo,
  hipercard, bankai,
}

/// The type of floating event.
enum FloatingType {
  pointer,
  gyroscope;

  bool get isPointer => this == pointer;

  bool get isGyroscope => this == gyroscope;
}
