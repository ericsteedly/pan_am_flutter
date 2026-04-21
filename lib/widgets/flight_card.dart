import 'package:flutter/material.dart';
import '../models/flight.dart';

String _formatTime(String raw) {
  final parts = raw.split(':');
  final hour = int.parse(parts[0]);
  final minute = parts[1];
  final period = hour < 12 ? 'AM' : 'PM';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour12:$minute $period';
}

String _formatDuration(String raw) {
  final parts = raw.split(':');
  final hours = int.parse(parts[0]);
  final minutes = parts[1].padLeft(2, '0');
  return '${hours}h ${minutes}m';
}

class FlightCard extends StatelessWidget {
  const FlightCard({
    super.key,
    required this.flightResult,
    required this.isSelected,
    required this.onTap,
  });

  final FlightResult flightResult;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (flightResult) {
      final DirectFlight f => _DirectFlightCard(
        flight: f,
        isSelected: isSelected,
        onTap: onTap,
      ),
      final ConnectedFlight f => _ConnectedFlightCard(
        flight: f,
        isSelected: isSelected,
        onTap: onTap,
      ),
    };
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? const Color(0xFFF3B12C) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

Widget _priceButton(double price, bool isSelected, VoidCallback onTap) {
  return FilledButton(
    onPressed: onTap,
    style: FilledButton.styleFrom(
      backgroundColor: isSelected ? const Color(0xFFF3B12C) : Colors.white,
      foregroundColor: isSelected ? Colors.white : Colors.black87,
      side: isSelected ? null : const BorderSide(color: Colors.black38),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    child: Text(
      '\$${price.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _nonstopBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF2E7D32),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Nonstop',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _stopBadge(String layoverCode) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.orange.shade700,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '1 Stop | Change Planes $layoverCode',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _DirectFlightCard extends StatelessWidget {
  const _DirectFlightCard({
    required this.flight,
    required this.isSelected,
    required this.onTap,
  });

  final DirectFlight flight;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f = flight.flight;
    return _CardShell(
      isSelected: isSelected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flight ${f.id}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              if (f.seats <= 5)
                Text(
                  '${f.seats} seats left',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${_formatTime(f.departureTime)}  →  ${_formatTime(f.arrivalTime)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _priceButton(f.price, isSelected, onTap),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _nonstopBadge(),
              const SizedBox(width: 12),
              Text(
                'Duration: ${_formatDuration(f.duration)}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectedFlightCard extends StatelessWidget {
  const _ConnectedFlightCard({
    required this.flight,
    required this.isSelected,
    required this.onTap,
  });

  final ConnectedFlight flight;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f1 = flight.flight1;
    final f2 = flight.flight2;
    return _CardShell(
      isSelected: isSelected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flight ${f1.id} / ${f2.id}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              if (flight.seats <= 5)
                Text(
                  '${flight.seats} seats left',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${_formatTime(f1.departureTime)}  →  ${_formatTime(f2.arrivalTime)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _priceButton(flight.totalPrice, isSelected, onTap),
            ],
          ),
          const SizedBox(height: 8),
          _stopBadge(flight.layoverCode),
          const SizedBox(height: 6),
          Text(
            'Duration: ${_formatDuration(flight.totalDuration)}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
