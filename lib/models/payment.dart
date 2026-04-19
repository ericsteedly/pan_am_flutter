class Payment {
  const Payment({
    required this.id,
    required this.merchant,
    this.cardNumber,
    required this.expirationDate,
    required this.firstName,
    required this.lastName,
    required this.obscuredNum,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      merchant: json['merchant'] as String,
      cardNumber: json['card_number'] as String?,
      expirationDate: json['expiration_date'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      obscuredNum: json['obscured_num'] as String,
    );
  }

  final int id;
  final String merchant;
  final String? cardNumber;
  final String expirationDate;
  final String firstName;
  final String lastName;
  final String obscuredNum;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant,
      if (cardNumber != null) 'card_number': cardNumber,
      'expiration_date': expirationDate,
      'first_name': firstName,
      'last_name': lastName,
      'obscured_num': obscuredNum,
    };
  }
}
