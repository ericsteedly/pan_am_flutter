import 'package:flutter/material.dart';
import '../widgets/pan_am_app_bar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PanAmAppBar(),
      body: const Center(child: Text('Register Screen')),
    );
  }
}
