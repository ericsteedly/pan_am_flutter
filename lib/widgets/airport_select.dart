import 'package:flutter/material.dart';
import '../models/airport.dart';

class AirportSelect extends StatelessWidget {
  const AirportSelect({
    super.key,
    required this.label,
    required this.airports,
    this.onChanged,
  });

  final String label;
  final List<Airport> airports;
  final void Function(Airport?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(
              label == 'Depart' ? Icons.flight_takeoff : Icons.flight_land,
              color: label == 'Depart'
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFDC0B0B),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Autocomplete<Airport>(
          displayStringForOption: (a) =>
              '${a.airportCode} - ${a.name}, ${a.city}',
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) return airports;
            final query = textEditingValue.text.toLowerCase();
            return airports.where(
              (a) =>
                  a.airportCode.toLowerCase().contains(query) ||
                  a.city.toLowerCase().contains(query) ||
                  a.name.toLowerCase().contains(query),
            );
          },
          onSelected: (airport) => onChanged?.call(airport),
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onSubmit(),
              onTap: () {
                controller.clear();
                onChanged?.call(null);
              },
              onChanged: (value) {
                if (value.isEmpty) onChanged?.call(null);
              },
              decoration: const InputDecoration(
                labelText: 'Where Would You Like To Fly? *',
                border: OutlineInputBorder(),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final airport = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          '${airport.airportCode} - ${airport.name}, ${airport.city}',
                        ),
                        onTap: () => onSelected(airport),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
