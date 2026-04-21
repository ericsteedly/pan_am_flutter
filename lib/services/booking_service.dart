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

  static Future<Booking> getBooking(int id) async {
    try {
      final response = await dio.get('/bookings/$id');
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch booking: ${e.message}');
    }
  }

  static Future<void> deleteBooking(int id) async {
    try {
      await dio.delete('/bookings/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete booking: ${e.message}');
    }
  }

  static Future<void> updateBookingPayment(int id, int paymentId) async {
    try {
      await dio.put('/bookings/$id', data: {'payment_id': paymentId});
    } on DioException catch (e) {
      throw Exception('Failed to update booking payment: ${e.message}');
    }
  }

  static Future<Booking> createBooking(List<int> flightIds) async {
    try {
      final response = await dio.post(
        '/bookings',
        data: flightIds.map((id) => {'flight_id': id}).toList(),
      );
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create booking: ${e.message}');
    }
  }
}
