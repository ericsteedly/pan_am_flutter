import 'package:flutter/material.dart';
import 'main_menu.dart';

class PanAmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PanAmAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1565C0),
      toolbarHeight: 120.0,
      centerTitle: false,
      titleSpacing: 16.0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fan Am Airways',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Pretending to book Pan Am flights since 2024',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: const [MainMenu()],
    );
  }
}
