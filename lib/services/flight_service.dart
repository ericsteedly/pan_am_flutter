import 'package:dio/dio.dart';

import '../models/flight.dart';
import 'dio_client.dart';

class FlightService {
  static Future<List<FlightResult>> getFlights({
    required int departureAirportId,
    required int arrivalAirportId,
    required String departureDay,
  }) async {
    try {
      final response = await dio.get(
        '/flights',
        queryParameters: {
          'departureAirport': departureAirportId,
          'arrivalAirport': arrivalAirportId,
          'departureDay': departureDay,
        },
      );
      return (response.data as List)
          .map((e) => FlightResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch flights: ${e.message}');
    }
  }
}
