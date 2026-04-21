import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../models/payment.dart';
import '../providers/flights_provider.dart';
import '../providers/payments_provider.dart';
import '../widgets/pan_am_app_bar.dart';

const _taxRate = 0.1436;
const _panAmBlue = Color(0xFF1565C0);

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  int? _selectedPaymentId;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final asyncFlights = ref.watch(flightsProvider);
    final asyncPayments = ref.watch(paymentsProvider);

    ref.listen(flightsProvider, (prev, next) {
      next.whenData((data) {
        if (data?.bookingConfirmed == true &&
            prev?.value?.bookingConfirmed != true) {
          ref.read(flightsProvider.notifier).reset();
          context.go('/bookings');
        }
      });
      if (next is AsyncError) {
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    ref.listen(paymentsProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load payment methods.')),
        );
      }
    });

    if (asyncFlights.isLoading && !_isBooking) {
      return const Scaffold(
        appBar: PanAmAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (asyncFlights.hasError && !_isBooking) {
      return Scaffold(
        appBar: const PanAmAppBar(),
        body: Center(
          child: Text('Something went wrong: ${asyncFlights.error}'),
        ),
      );
    }

    final flightsState = asyncFlights.value;
    if (flightsState == null || flightsState.departBooking == null) {
      return Scaffold(
        appBar: const PanAmAppBar(),
        body: const Center(child: Text('No booking data available.')),
      );
    }

    final departBooking = flightsState.departBooking!;
    final returnBooking = flightsState.returnBooking;
    final isRoundtrip = returnBooking != null;
    final payments = asyncPayments.value ?? [];

    return Scaffold(
      appBar: const PanAmAppBar(),
      backgroundColor: const Color(0xFFEEEEEE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Flight details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 700;
                        final flightPanel = _FlightPanel(
                          departBooking: departBooking,
                          returnBooking: returnBooking,
                        );
                        final pricePanel = _PricePanel(
                          departBooking: departBooking,
                          returnBooking: returnBooking,
                          isRoundtrip: isRoundtrip,
                        );
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: flightPanel),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: pricePanel),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            flightPanel,
                            const SizedBox(height: 16),
                            pricePanel,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _PaymentRow(
                      payments: payments,
                      selectedPaymentId: _selectedPaymentId,
                      onPaymentSelected: (id) =>
                          setState(() => _selectedPaymentId = id),
                      onBook: _selectedPaymentId == null || _isBooking
                          ? null
                          : () {
                              setState(() => _isBooking = true);
                              ref
                                  .read(flightsProvider.notifier)
                                  .bookTrip(_selectedPaymentId!);
                            },
                      onCancel: () {
                        ref.read(flightsProvider.notifier).cancelAndReset();
                        context.go('/search');
                      },
                      isBooking: _isBooking,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '*Do not use real payment info!',
                      style: TextStyle(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlightPanel extends StatelessWidget {
  const _FlightPanel({required this.departBooking, this.returnBooking});

  final Booking departBooking;
  final Booking? returnBooking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BookingRow(booking: departBooking),
        if (returnBooking != null) ...[
          const Divider(color: Color(0xFFFFB300), thickness: 2),
          _BookingRow(booking: returnBooking!),
        ],
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final tickets = booking.tickets;
    if (tickets.isEmpty) return const SizedBox.shrink();
    final firstFlight = tickets.first.flight;
    final lastFlight = tickets.last.flight;
    final stopCount = tickets.length - 1;

    final dateStr = _formatDate(firstFlight.departureDay);
    final route =
        '${firstFlight.departureAirport.airportCode} to ${lastFlight.arrivalAirport.airportCode}';
    final times =
        '${_formatTime(firstFlight.departureTime)} - ${_formatTime(lastFlight.arrivalTime)}';
    final stopLabel = stopCount == 0
        ? 'Nonstop'
        : '$stopCount stop${stopCount > 1 ? 's' : ''}';

    final layoverCities = stopCount > 0
        ? tickets
              .sublist(0, tickets.length - 1)
              .map((t) => t.flight.arrivalAirport.city)
              .join(', ')
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(dateStr, style: const TextStyle(fontSize: 15)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(times, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(stopLabel, style: const TextStyle(fontSize: 13)),
              ),
              if (layoverCities != null) ...[
                const SizedBox(height: 4),
                Text(
                  layoverCities,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ],
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

class _PricePanel extends StatelessWidget {
  const _PricePanel({
    required this.departBooking,
    required this.returnBooking,
    required this.isRoundtrip,
  });

  final Booking departBooking;
  final Booking? returnBooking;
  final bool isRoundtrip;

  @override
  Widget build(BuildContext context) {
    final departPrice = departBooking.totalPrice;
    final returnPrice = returnBooking?.totalPrice ?? 0.0;
    final baseTotal = isRoundtrip ? departPrice + returnPrice : departPrice;
    final taxes = baseTotal * _taxRate;
    final totalPerPassenger = baseTotal + taxes;

    return Container(
      decoration: BoxDecoration(
        color: _panAmBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        child: Column(
          children: [
            if (isRoundtrip) ...[
              _PriceRow(
                label: 'Departure Price per passenger',
                labelBold: true,
                labelPrefix: 'Departure ',
                amount: departPrice,
              ),
              _PriceRow(
                label: 'Return Price per passenger',
                labelBold: true,
                labelPrefix: 'Return ',
                amount: returnPrice,
              ),
            ] else
              _PriceRow(label: 'Price per passenger', amount: departPrice),
            _PriceRow(label: 'Taxes and Fees per passenger', amount: taxes),
            _PriceRow(label: 'Total per passenger', amount: totalPerPassenger),
            _PriceRow(label: 'Number of passengers', rawValue: 'x1'),
            const Divider(color: Colors.white70, thickness: 1.5),
            _PriceRow(
              label: isRoundtrip ? 'Trip Total' : 'Flight Total',
              amount: totalPerPassenger,
              bold: true,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    this.amount,
    this.rawValue,
    this.bold = false,
    this.fontSize = 14,
    this.labelBold = false,
    this.labelPrefix,
  });

  final String label;
  final double? amount;
  final String? rawValue;
  final bool bold;
  final double fontSize;
  final bool labelBold;
  final String? labelPrefix;

  @override
  Widget build(BuildContext context) {
    final valueText = amount != null
        ? '\$${amount!.toStringAsFixed(2)}'
        : (rawValue ?? '');

    Widget labelWidget;
    if (labelPrefix != null && labelBold) {
      labelWidget = RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: labelPrefix!,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: label.replaceFirst(labelPrefix!, ''),
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
          ],
        ),
      );
    } else {
      labelWidget = Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: labelWidget),
          Text(
            valueText,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payments,
    required this.selectedPaymentId,
    required this.onPaymentSelected,
    required this.onBook,
    required this.onCancel,
    required this.isBooking,
  });

  final List<Payment> payments;
  final int? selectedPaymentId;
  final ValueChanged<int?> onPaymentSelected;
  final VoidCallback? onBook;
  final VoidCallback onCancel;
  final bool isBooking;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.credit_card),
          label: const Text('NEW'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _panAmBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _panAmBlue,
            disabledForegroundColor: Colors.white,
          ),
        ),
        SizedBox(
          width: 260,
          child: DropdownButtonFormField<int>(
            initialValue: selectedPaymentId,
            items: payments
                .map(
                  (p) => DropdownMenuItem<int>(
                    value: p.id,
                    child: Text(
                      '${p.merchant} ···· ${p.obscuredNum}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onPaymentSelected,
            hint: const Text('Select a Payment'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              isDense: true,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFFFB300),
            disabledForegroundColor: Colors.white,
          ),
          child: isBooking
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('BOOK TRIP!'),
        ),
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFFB300),
            side: const BorderSide(color: Color(0xFFFFB300)),
          ),
          child: const Text('CANCEL BOOKING'),
        ),
      ],
    );
  }
}
