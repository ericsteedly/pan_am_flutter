import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white, size: 32),
      offset: const Offset(0, 56),
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'search':
            context.go('/search');
          case 'account':
            context.go('/account/me');
          case 'bookings':
            context.go('/bookings');
          case 'logout':
            onLogout?.call();
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
