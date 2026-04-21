import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight.dart';
import '../services/booking_service.dart';
import '../services/flight_service.dart';

enum FlightLeg { depart, returnLeg }

class FlightsState {
  const FlightsState({
    required this.tripType,
    required this.departFlights,
    this.returnFlights,
    this.leg = FlightLeg.depart,
    this.selectedDepartFlight,
    this.selectedReturnFlight,
    this.departBookingId,
    this.returnBookingId,
  });

  final String tripType;
  final FlightLeg leg;
  final List<FlightResult> departFlights;
  final List<FlightResult>? returnFlights;
  final FlightResult? selectedDepartFlight;
  final FlightResult? selectedReturnFlight;
  final int? departBookingId;
  final int? returnBookingId;

  FlightsState copyWith({
    String? tripType,
    FlightLeg? leg,
    List<FlightResult>? departFlights,
    Object? returnFlights = _sentinel,
    Object? selectedDepartFlight = _sentinel,
    Object? selectedReturnFlight = _sentinel,
    Object? departBookingId = _sentinel,
    Object? returnBookingId = _sentinel,
  }) {
    return FlightsState(
      tripType: tripType ?? this.tripType,
      leg: leg ?? this.leg,
      departFlights: departFlights ?? this.departFlights,
      returnFlights: returnFlights == _sentinel
          ? this.returnFlights
          : returnFlights as List<FlightResult>?,
      selectedDepartFlight: selectedDepartFlight == _sentinel
          ? this.selectedDepartFlight
          : selectedDepartFlight as FlightResult?,
      selectedReturnFlight: selectedReturnFlight == _sentinel
          ? this.selectedReturnFlight
          : selectedReturnFlight as FlightResult?,
      departBookingId: departBookingId == _sentinel
          ? this.departBookingId
          : departBookingId as int?,
      returnBookingId: returnBookingId == _sentinel
          ? this.returnBookingId
          : returnBookingId as int?,
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

  Future<void> selectDepartFlight(FlightResult flight) async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bookingId = await BookingService.createBooking(flight.flightIds);
      return current.copyWith(
        selectedDepartFlight: flight,
        departBookingId: bookingId,
        leg: FlightLeg.returnLeg,
      );
    });
  }

  Future<void> confirmReturnFlight(FlightResult flight) async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bookingId = await BookingService.createBooking(flight.flightIds);
      return current.copyWith(
        selectedReturnFlight: flight,
        returnBookingId: bookingId,
      );
    });
  }

  void resetToDepart() {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        leg: FlightLeg.depart,
        selectedDepartFlight: null,
        departBookingId: null,
      ),
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

final flightsProvider = AsyncNotifierProvider<FlightsNotifier, FlightsState?>(
  FlightsNotifier.new,
);
