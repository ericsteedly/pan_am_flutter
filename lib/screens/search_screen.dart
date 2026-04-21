import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/airport.dart';
import '../providers/airports_provider.dart';
import '../providers/flights_provider.dart';
import '../providers/search_form_provider.dart';
import '../widgets/airport_select.dart';
import '../widgets/pan_am_app_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _departDateController = TextEditingController();
  final _returnDateController = TextEditingController();

  @override
  void dispose() {
    _departDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  String _formatDisplay(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _formatApi(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDepartDate(SearchFormState formState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.departDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: formState.departDateLastDate,
    );
    if (picked != null && mounted) {
      _departDateController.text = _formatDisplay(picked);
      ref.read(searchFormProvider.notifier).setDepartDate(picked);
    }
  }

  Future<void> _pickReturnDate(SearchFormState formState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.returnDate ?? formState.returnDateFirstDate,
      firstDate: formState.returnDateFirstDate,
      lastDate: DateTime(2026, 6, 30),
    );
    if (picked != null && mounted) {
      _returnDateController.text = _formatDisplay(picked);
      ref.read(searchFormProvider.notifier).setReturnDate(picked);
    }
  }

  void _onSearch(SearchFormState formState) {
    if (!ref.read(searchFormProvider.notifier).validate()) return;
    ref
        .read(flightsProvider.notifier)
        .search(
          departureAirportId: formState.departAirport!.id,
          arrivalAirportId: formState.arriveAirport!.id,
          departureDay: _formatApi(formState.departDate!),
          tripType: formState.tripType,
          returnDay: formState.returnDate != null
              ? _formatApi(formState.returnDate!)
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(searchFormProvider);
    final airportsAsync = ref.watch(airportsProvider);
    final isSearching = ref.watch(flightsProvider).isLoading;

    // Sync controllers when notifier clears dates due to constraints
    ref.listen(searchFormProvider, (prev, next) {
      if (next.departDate == null && prev?.departDate != null) {
        _departDateController.clear();
      }
      if (next.returnDate == null && prev?.returnDate != null) {
        _returnDateController.clear();
      }
    });

    // Navigate on successful search; show snackbar on error
    ref.listen(flightsProvider, (_, next) {
      next.whenData((data) {
        if (data != null) context.go('/results');
      });
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: ${next.error}')));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const PanAmAppBar(),
      body: airportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load airports: $e')),
        data: (airports) =>
            _buildForm(context, formState, airports, isSearching),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    SearchFormState formState,
    List<Airport> airports,
    bool isSearching,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Book a Flight',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RadioGroup<String>(
                  groupValue: formState.tripType,
                  onChanged: (v) =>
                      ref.read(searchFormProvider.notifier).setTripType(v!),
                  child: const Row(
                    children: [
                      Radio<String>(value: 'oneway'),
                      Text('Oneway'),
                      Radio<String>(value: 'roundtrip'),
                      Text('Roundtrip'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AirportSelect(
                  label: 'Depart',
                  airports: ref
                      .read(searchFormProvider.notifier)
                      .availableDepartAirports(airports),
                  onChanged: (a) =>
                      ref.read(searchFormProvider.notifier).setDepartAirport(a),
                ),
                AirportSelect(
                  label: 'Arrive',
                  airports: ref
                      .read(searchFormProvider.notifier)
                      .availableArriveAirports(airports),
                  onChanged: (a) =>
                      ref.read(searchFormProvider.notifier).setArriveAirport(a),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _departDateController,
                  readOnly: true,
                  onTap: () => _pickDepartDate(formState),
                  decoration: const InputDecoration(
                    labelText: 'Depart Date',
                    hintText: 'MM/DD/YYYY',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _returnDateController,
                  readOnly: true,
                  enabled: formState.tripType == 'roundtrip',
                  onTap: () => _pickReturnDate(formState),
                  decoration: const InputDecoration(
                    labelText: 'Return Date',
                    hintText: 'MM/DD/YYYY',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '* No flights exist beyond JUNE 30, 2026',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                if (formState.errors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...formState.errors.map(
                    (e) => Text(
                      e,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSearching ? null : () => _onSearch(formState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3B12C),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF3B12C),
                      disabledForegroundColor: Colors.white,
                    ),
                    child: isSearching
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('SEARCH FLIGHT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
