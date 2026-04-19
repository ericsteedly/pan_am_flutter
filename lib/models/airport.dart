class Airport {
  const Airport({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.airportCode,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      airportCode: json['airport_code'] as String,
    );
  }

  final int id;
  final String name;
  final String city;
  final String state;
  final String country;
  final String airportCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'state': state,
      'country': country,
      'airport_code': airportCode,
    };
  }
}
