import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight.dart';
import '../services/flight_service.dart';

enum FlightLeg { depart, returnLeg }

class FlightsState {
  const FlightsState({
    required this.tripType,
    required this.departFlights,
    this.returnFlights,
    this.leg = FlightLeg.depart,
    this.selectedDepartFlight,
  });

  final String tripType;
  final FlightLeg leg;
  final List<Flight> departFlights;
  final List<Flight>? returnFlights;
  final Flight? selectedDepartFlight;

  FlightsState copyWith({
    String? tripType,
    FlightLeg? leg,
    List<Flight>? departFlights,
    Object? returnFlights = _sentinel,
    Object? selectedDepartFlight = _sentinel,
  }) {
    return FlightsState(
      tripType: tripType ?? this.tripType,
      leg: leg ?? this.leg,
      departFlights: departFlights ?? this.departFlights,
      returnFlights: returnFlights == _sentinel
          ? this.returnFlights
          : returnFlights as List<Flight>?,
      selectedDepartFlight: selectedDepartFlight == _sentinel
          ? this.selectedDepartFlight
          : selectedDepartFlight as Flight?,
    );
  }
}

const _sentinel = Object();

class FlightsNotifier extends AsyncNotifier<FlightsState?> {
  @override
  FlightsState? build() => null;

  Future<void> search({
    required int departureAirportId,
    required int arrivalAirportId,
    required String departureDay,
    required String tripType,
    String? returnDay,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isRoundtrip = tripType == 'roundtrip' && returnDay != null;
      if (isRoundtrip) {
        final results = await Future.wait([
          FlightService.getFlights(
            departureAirportId: departureAirportId,
            arrivalAirportId: arrivalAirportId,
            departureDay: departureDay,
          ),
          FlightService.getFlights(
            departureAirportId: arrivalAirportId,
            arrivalAirportId: departureAirportId,
            departureDay: returnDay,
          ),
        ]);
        return FlightsState(
          tripType: tripType,
          departFlights: results[0],
          returnFlights: results[1],
        );
      } else {
        final departFlights = await FlightService.getFlights(
          departureAirportId: departureAirportId,
          arrivalAirportId: arrivalAirportId,
          departureDay: departureDay,
        );
        return FlightsState(tripType: tripType, departFlights: departFlights);
      }
    });
  }

  void selectDepartFlight(Flight flight) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(selectedDepartFlight: flight, leg: FlightLeg.returnLeg),
    );
  }
}

final flightsProvider = AsyncNotifierProvider<FlightsNotifier, FlightsState?>(
  FlightsNotifier.new,
);
