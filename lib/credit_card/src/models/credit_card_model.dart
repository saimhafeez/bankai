class CreditCardModel {
  CreditCardModel(this.cardNumber, this.expiryDate, this.cardHolderName,
      this.cvvCode, this.isCvvFocused, this.issueDate, this.bankName, this.cardHolderCnic,
      this.cardType);

  /// Number of the credit/debit card.
  String cardNumber = '';

  /// Expiry date of the card.
  String expiryDate = '';

  /// Name of the card holder.
  String cardHolderName = '';

  /// Cvv code on card.
  String cvvCode = '';

  /// A boolean for indicating if cvv is focused or not.
  bool isCvvFocused = false;

  /// Custom
  String issueDate = '';
  String bankName = '';
  String cardHolderCnic = '';
  String cardType = 'debit';

}
