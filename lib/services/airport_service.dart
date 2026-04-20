import 'package:dio/dio.dart';

import '../models/airport.dart';
import 'dio_client.dart';

class AirportService {
  static Future<List<Airport>> getAirports() async {
    try {
      final response = await dio.get('/airports');
      return (response.data as List)
          .map((e) => Airport.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch airports: ${e.message}');
    }
  }
}
