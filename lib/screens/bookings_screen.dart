import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../providers/bookings_provider.dart';
import '../widgets/pan_am_app_bar.dart';

const _panAmBlue = Color(0xFF1565C0);

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      ref.invalidate(bookingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBookings = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: const PanAmAppBar(),
      backgroundColor: const Color(0xFFEEEEEE),
      body: asyncBookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load bookings: $e')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flight, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookings yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) =>
                _BookingCard(booking: bookings[index]),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final tickets = booking.tickets;
    if (tickets.isEmpty) return const SizedBox.shrink();

    final firstFlight = tickets.first.flight;
    final lastFlight = tickets.last.flight;
    final stopCount = tickets.length - 1;

    final flightLabel = 'Flight#${firstFlight.id}';
    final destinationCity = lastFlight.arrivalAirport.city;
    final dateStr = _formatDate(firstFlight.departureDay);
    final route =
        '${firstFlight.departureAirport.airportCode} to ${lastFlight.arrivalAirport.airportCode}';
    final times =
        '${_formatTime(firstFlight.departureTime)} - ${_formatTime(lastFlight.arrivalTime)}';
    final stopLabel = stopCount == 0
        ? 'Nonstop'
        : '$stopCount stop${stopCount > 1 ? 's' : ''}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flightLabel,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              destinationCity,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _panAmBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(dateStr, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(times, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(stopLabel, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return DateFormat('EEEE, MMMM d').format(date);
  }

  static String _formatTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final dt = DateTime(0, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(dt);
  }
}
