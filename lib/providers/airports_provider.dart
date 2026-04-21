import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/airport.dart';
import '../services/airport_service.dart';

class AirportsNotifier extends AsyncNotifier<List<Airport>> {
  @override
  Future<List<Airport>> build() => AirportService.getAirports();
}

final airportsProvider = AsyncNotifierProvider<AirportsNotifier, List<Airport>>(
  AirportsNotifier.new,
);
