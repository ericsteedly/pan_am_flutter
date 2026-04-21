import 'package:flutter/material.dart';
import '../widgets/pan_am_app_bar.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PanAmAppBar(),
      body: const Center(child: Text('Booking Screen')),
    );
  }
}
