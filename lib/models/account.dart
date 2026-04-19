import 'payment.dart';

class Account {
  const Account({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.payments,
    this.dateOfBirth,
    this.phoneNumber,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return Account(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      payments: (json['payments'] as List<dynamic>)
          .map((p) => Payment.fromJson(p as Map<String, dynamic>))
          .toList(),
      dateOfBirth: customer?['date_of_birth'] as String?,
      phoneNumber: customer?['phone_number'] as String?,
    );
  }

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final List<Payment> payments;
  final String? dateOfBirth;
  final String? phoneNumber;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'payments': payments.map((p) => p.toJson()).toList(),
      'customer': {
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      },
    };
  }
}
