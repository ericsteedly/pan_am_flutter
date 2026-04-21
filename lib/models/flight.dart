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
      points: (json['points'] as int?) ?? 0,
      seats: (json['seats'] as int?) ?? 0,
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

/// Union type for items returned by the /flights endpoint.
/// Direct flights have a top-level `id`; connected flights have `flight1`/`flight2`.
sealed class FlightResult {
  const FlightResult();

  factory FlightResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('flight1')) {
      return ConnectedFlight.fromJson(json);
    }
    return DirectFlight.fromJson(json);
  }

  List<int> get flightIds;
  double get price;
}

class DirectFlight extends FlightResult {
  const DirectFlight(this.flight);

  factory DirectFlight.fromJson(Map<String, dynamic> json) =>
      DirectFlight(Flight.fromJson(json));

  final Flight flight;

  @override
  List<int> get flightIds => [flight.id];

  @override
  double get price => flight.price;
}

class ConnectedFlight extends FlightResult {
  ConnectedFlight({
    required this.flight1,
    required this.flight2,
    required this.totalDuration,
    required this.totalPrice,
    required this.totalPoints,
  });

  factory ConnectedFlight.fromJson(Map<String, dynamic> json) {
    return ConnectedFlight(
      flight1: Flight.fromJson(json['flight1'] as Map<String, dynamic>),
      flight2: Flight.fromJson(json['flight2'] as Map<String, dynamic>),
      totalDuration: json['total_duration'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      totalPoints: (json['total_points'] as int?) ?? 0,
    );
  }

  final Flight flight1;
  final Flight flight2;
  final String totalDuration;
  final double totalPrice;
  final int totalPoints;

  /// Layover airport is flight1's arrival airport.
  String get layoverCode => flight1.arrivalAirport.airportCode;

  /// Effective seats is the minimum across both legs.
  int get seats =>
      flight1.seats < flight2.seats ? flight1.seats : flight2.seats;

  @override
  List<int> get flightIds => [flight1.id, flight2.id];

  @override
  double get price => totalPrice;
}
