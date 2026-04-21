import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/flight.dart';
import '../providers/flights_provider.dart';
import '../providers/search_form_provider.dart';
import '../widgets/flight_card.dart';
import '../widgets/pan_am_app_bar.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  FlightResult? _selectedFlight;

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatHeaderDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';

  void _handleBack(FlightsState flightsState) {
    if (flightsState.leg == FlightLeg.returnLeg) {
      ref.read(flightsProvider.notifier).resetToDepart();
      setState(() => _selectedFlight = null);
    } else {
      ref.read(flightsProvider.notifier).reset();
      context.go('/search');
    }
  }

  void _handleAction(FlightsState flightsState) {
    final flight = _selectedFlight;
    if (flight == null) return;
    if (flightsState.leg == FlightLeg.depart &&
        flightsState.tripType == 'roundtrip') {
      ref.read(flightsProvider.notifier).selectDepartFlight(flight);
    } else {
      ref.read(flightsProvider.notifier).confirmReturnFlight(flight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flightsAsync = ref.watch(flightsProvider);
    final formState = ref.watch(searchFormProvider);

    ref.listen(flightsProvider, (prev, next) {
      if (prev?.value?.leg != next.value?.leg) {
        setState(() => _selectedFlight = null);
      }
      next.whenData((data) {
        if (data?.selectedReturnFlight != null &&
            prev?.value?.selectedReturnFlight == null) {
          context.go('/purchase');
        }
      });
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    final isLoading = flightsAsync.isLoading;

    return flightsAsync.when(
      loading: () => Scaffold(
        appBar: const PanAmAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: const PanAmAppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (flightsState) {
        if (flightsState == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/search');
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return _buildResults(context, flightsState, formState, isLoading);
      },
    );
  }

  Widget _buildResults(
    BuildContext context,
    FlightsState flightsState,
    SearchFormState formState,
    bool isLoading,
  ) {
    final isReturnLeg = flightsState.leg == FlightLeg.returnLeg;
    final isRoundtripDepart =
        flightsState.tripType == 'roundtrip' && !isReturnLeg;
    final flights = isReturnLeg
        ? (flightsState.returnFlights ?? [])
        : flightsState.departFlights;

    final departCode = formState.departAirport?.airportCode ?? '';
    final arriveCode = formState.arriveAirport?.airportCode ?? '';
    final headerLabel = isReturnLeg ? 'Return' : 'Depart';
    final headerRoute = isReturnLeg
        ? '$arriveCode → $departCode'
        : '$departCode → $arriveCode';
    final headerDate = isReturnLeg
        ? (formState.returnDate != null
              ? _formatHeaderDate(formState.returnDate!)
              : '')
        : (formState.departDate != null
              ? _formatHeaderDate(formState.departDate!)
              : '');

    final buttonLabel = isRoundtripDepart ? 'NEXT FLIGHT' : 'CONTINUE';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(flightsState);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E0E0),
        appBar: const PanAmAppBar(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _handleBack(flightsState),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(
                      isReturnLeg ? 'Back to Depart' : 'Back to Search',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$headerLabel: $headerRoute',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    headerDate,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Expanded(
              child: flights.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: flights.length,
                      itemBuilder: (context, index) {
                        final flight = flights[index];
                        return FlightCard(
                          flightResult: flight,
                          isSelected: _selectedFlight == flight,
                          onTap: () => setState(() => _selectedFlight = flight),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || _selectedFlight == null
                      ? null
                      : () => _handleAction(flightsState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3B12C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFF3B12C),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.airplanemode_inactive,
            size: 64,
            color: Colors.black26,
          ),
          const SizedBox(height: 16),
          const Text(
            'No flights found for this route.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(flightsProvider.notifier).reset();
              context.go('/search');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Search'),
          ),
        ],
      ),
    );
  }
}
