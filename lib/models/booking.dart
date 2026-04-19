import 'flight.dart';

class Ticket {
  const Ticket({
    required this.id,
    required this.bookingId,
    required this.flight,
    required this.userId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      flight: Flight.fromJson(json['flight'] as Map<String, dynamic>),
      userId: json['user_id'] as int,
    );
  }

  final int id;
  final int bookingId;
  final Flight flight;
  final int userId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'flight': flight.toJson(),
      'user_id': userId,
    };
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    this.paymentId,
    this.rewardsPayment,
    required this.tickets,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      paymentId: json['payment_id'] as int?,
      rewardsPayment: json['rewards_payment'] as bool?,
      tickets: (json['tickets'] as List<dynamic>)
          .map((t) => Ticket.fromJson(t as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  final int id;
  final int userId;
  final int? paymentId;
  final bool? rewardsPayment;
  final List<Ticket> tickets;
  final double totalPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payment_id': paymentId,
      'rewards_payment': rewardsPayment,
      'tickets': tickets.map((t) => t.toJson()).toList(),
      'total_price': totalPrice,
    };
  }
}
