import 'package:dio/dio.dart';

import '../models/payment.dart';
import 'dio_client.dart';

class PaymentService {
  static Future<List<Payment>> getPayments() async {
    try {
      final response = await dio.get('/payments');
      return (response.data as List)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch payments: ${e.message}');
    }
  }
}
