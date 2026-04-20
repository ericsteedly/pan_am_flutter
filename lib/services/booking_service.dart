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
}
