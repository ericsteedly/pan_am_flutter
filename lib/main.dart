import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  //TEMP TOKEN DELETE, REMOVE AFTER LOGOUT CREATED
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.deleteToken();
  //
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
