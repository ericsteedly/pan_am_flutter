import 'package:flutter/material.dart';
import '../widgets/pan_am_app_bar.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PanAmAppBar(),
      body: const Center(child: Text('Results Screen')),
    );
  }
}
