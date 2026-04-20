import 'package:flutter/material.dart';
import '../widgets/airport_select.dart';
import '../widgets/pan_am_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _tripType = 'roundtrip';
  final _departDateController = TextEditingController();
  final _returnDateController = TextEditingController();

  @override
  void dispose() {
    _departDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 6, 30),
    );
    if (picked != null && mounted) {
      controller.text =
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const PanAmAppBar(),
      body: SingleChildScrollView(
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
                    groupValue: _tripType,
                    onChanged: (v) => setState(() => _tripType = v!),
                    child: Row(
                      children: [
                        const Radio<String>(value: 'oneway'),
                        const Text('Oneway'),
                        const Radio<String>(value: 'roundtrip'),
                        const Text('Roundtrip'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AirportSelect(label: 'Depart', airports: const []),
                  AirportSelect(label: 'Arrive', airports: const []),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _departDateController,
                    readOnly: true,
                    onTap: () => _pickDate(_departDateController),
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
                    enabled: _tripType == 'roundtrip',
                    onTap: () => _pickDate(_returnDateController),
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B12C),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFF3B12C),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: const Text('SEARCH FLIGHT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
