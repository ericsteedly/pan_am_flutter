import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingsNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    final bookings = await BookingService.getBookings();
    bookings.sort((a, b) {
      final aDate = a.tickets.isNotEmpty
          ? a.tickets.first.flight.departureDay
          : '';
      final bDate = b.tickets.isNotEmpty
          ? b.tickets.first.flight.departureDay
          : '';
      return aDate.compareTo(bDate);
    });
    return bookings;
  }
}

final bookingsProvider = AsyncNotifierProvider<BookingsNotifier, List<Booking>>(
  BookingsNotifier.new,
);
