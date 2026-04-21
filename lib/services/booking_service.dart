import 'package:dio/dio.dart';

import '../models/booking.dart';
import 'dio_client.dart';

class BookingService {
  static Future<List<Booking>> getBookings() async {
    try {
      final response = await dio.get('/bookings');
      return (response.data as List)
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch bookings: ${e.message}');
    }
  }

  static Future<int> createBooking(List<int> flightIds) async {
    try {
      final response = await dio.post(
        '/bookings',
        data: flightIds.map((id) => {'flight_id': id}).toList(),
      );
      return response.data['id'] as int;
    } on DioException catch (e) {
      throw Exception('Failed to create booking: ${e.message}');
    }
  }
}
