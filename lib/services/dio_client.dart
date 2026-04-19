import 'package:dio/dio.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://panamapi.dev',
    headers: {'Content-Type': 'application/json'},
  ),
);
