import 'airport.dart';

class Flight {
  const Flight({
    required this.id,
    required this.departureDay,
    required this.departureTime,
    required this.arrivalDay,
    required this.arrivalTime,
    required this.price,
    required this.points,
    required this.seats,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.duration,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] as int,
      departureDay: json['departureDay'] as String,
      departureTime: json['departureTime'] as String,
      arrivalDay: json['arrivalDay'] as String,
      arrivalTime: json['arrivalTime'] as String,
      price: (json['price'] as num).toDouble(),
      points: json['points'] as int,
      seats: json['seats'] as int,
      departureAirport: Airport.fromJson(
        json['departureAirport'] as Map<String, dynamic>,
      ),
      arrivalAirport: Airport.fromJson(
        json['arrivalAirport'] as Map<String, dynamic>,
      ),
      duration: json['duration'] as String,
    );
  }

  final int id;
  final String departureDay;
  final String departureTime;
  final String arrivalDay;
  final String arrivalTime;
  final double price;
  final int points;
  final int seats;
  final Airport departureAirport;
  final Airport arrivalAirport;
  final String duration;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departureDay': departureDay,
      'departureTime': departureTime,
      'arrivalDay': arrivalDay,
      'arrivalTime': arrivalTime,
      'price': price,
      'points': points,
      'seats': seats,
      'departureAirport': departureAirport.toJson(),
      'arrivalAirport': arrivalAirport.toJson(),
      'duration': duration,
    };
  }
}
