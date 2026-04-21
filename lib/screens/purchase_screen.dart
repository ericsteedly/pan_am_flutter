import 'package:flutter/material.dart';
import '../widgets/pan_am_app_bar.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PanAmAppBar(),
      body: const Center(child: Text('Purchase Screen')),
    );
  }
}
