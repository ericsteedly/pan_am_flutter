import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentsNotifier extends AsyncNotifier<List<Payment>> {
  @override
  Future<List<Payment>> build() => PaymentService.getPayments();
}

final paymentsProvider = AsyncNotifierProvider<PaymentsNotifier, List<Payment>>(
  PaymentsNotifier.new,
);
