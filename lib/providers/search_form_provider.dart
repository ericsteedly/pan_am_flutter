import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/airport.dart';

class SearchFormState {
  const SearchFormState({
    this.tripType = 'roundtrip',
    this.departAirport,
    this.arriveAirport,
    this.departDate,
    this.returnDate,
    this.errors = const [],
  });

  final String tripType;
  final Airport? departAirport;
  final Airport? arriveAirport;
  final DateTime? departDate;
  final DateTime? returnDate;
  final List<String> errors;

  SearchFormState copyWith({
    String? tripType,
    Object? departAirport = _sentinel,
    Object? arriveAirport = _sentinel,
    Object? departDate = _sentinel,
    Object? returnDate = _sentinel,
    List<String>? errors,
  }) {
    return SearchFormState(
      tripType: tripType ?? this.tripType,
      departAirport: departAirport == _sentinel
          ? this.departAirport
          : departAirport as Airport?,
      arriveAirport: arriveAirport == _sentinel
          ? this.arriveAirport
          : arriveAirport as Airport?,
      departDate: departDate == _sentinel
          ? this.departDate
          : departDate as DateTime?,
      returnDate: returnDate == _sentinel
          ? this.returnDate
          : returnDate as DateTime?,
      errors: errors ?? this.errors,
    );
  }

  DateTime get returnDateFirstDate => departDate ?? DateTime.now();

  DateTime get departDateLastDate => returnDate ?? DateTime(2026, 6, 30);
}

const _sentinel = Object();

class SearchFormNotifier extends Notifier<SearchFormState> {
  @override
  SearchFormState build() => const SearchFormState();

  List<Airport> availableDepartAirports(List<Airport> all) {
    final arrive = state.arriveAirport;
    return arrive == null ? all : all.where((a) => a.id != arrive.id).toList();
  }

  List<Airport> availableArriveAirports(List<Airport> all) {
    final depart = state.departAirport;
    return depart == null ? all : all.where((a) => a.id != depart.id).toList();
  }

  void setTripType(String tripType) {
    state = state.copyWith(
      tripType: tripType,
      returnDate: tripType == 'oneway' ? null : _sentinel,
      errors: state.errors.where((e) => !e.contains('Return')).toList(),
    );
  }

  void setDepartAirport(Airport? airport) {
    state = state.copyWith(departAirport: airport);
  }

  void setArriveAirport(Airport? airport) {
    state = state.copyWith(arriveAirport: airport);
  }

  void setDepartDate(DateTime? date) {
    final shouldClearReturn =
        date != null &&
        state.returnDate != null &&
        state.returnDate!.isBefore(date);
    state = state.copyWith(
      departDate: date,
      returnDate: shouldClearReturn ? null : _sentinel,
    );
  }

  void setReturnDate(DateTime? date) {
    final shouldClearDepart =
        date != null &&
        state.departDate != null &&
        state.departDate!.isAfter(date);
    state = state.copyWith(
      returnDate: date,
      departDate: shouldClearDepart ? null : _sentinel,
    );
  }

  bool validate() {
    final errors = <String>[];
    if (state.departAirport == null) {
      errors.add('Departure airport is required');
    }
    if (state.arriveAirport == null) errors.add('Arrival airport is required');
    if (state.departDate == null) errors.add('Departure date is required');
    if (state.tripType == 'roundtrip' && state.returnDate == null) {
      errors.add('Return date is required for roundtrip');
    }
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }
}

final searchFormProvider =
    NotifierProvider<SearchFormNotifier, SearchFormState>(
      SearchFormNotifier.new,
    );
