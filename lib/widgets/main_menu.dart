import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/flights_provider.dart';

class MainMenu extends ConsumerWidget {
  const MainMenu({super.key});

  static void _cleanupBookings(WidgetRef ref) {
    final flightsState = ref.read(flightsProvider).value;
    if (flightsState?.departBooking != null ||
        flightsState?.returnBooking != null) {
      ref.read(flightsProvider.notifier).cancelAndReset();
    }
  }

  static void _cleanupAndNavigate(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) {
    _cleanupBookings(ref);
    context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white, size: 32),
      offset: const Offset(0, 56),
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'search':
            _cleanupAndNavigate(context, ref, '/search');
          case 'account':
            _cleanupAndNavigate(context, ref, '/account/me');
          case 'bookings':
            _cleanupAndNavigate(context, ref, '/bookings');
          case 'logout':
            _cleanupBookings(ref);
            ref.read(authProvider.notifier).logout();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'search', child: Text('Book Flight')),
        PopupMenuItem(value: 'account', child: Text('Account')),
        PopupMenuItem(value: 'bookings', child: Text('Bookings')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }
}
