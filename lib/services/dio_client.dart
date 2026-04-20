import 'package:dio/dio.dart';
import 'storage_service.dart';

final dio =
    Dio(
        BaseOptions(
          baseUrl: 'https://panamapi.dev',
          headers: {'Content-Type': 'application/json'},
        ),
      )
      ..interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = await StorageService.readToken();
              if (token != null) {
                options.headers['Authorization'] = 'Token $token';
              }
            } catch (_) {}
            handler.next(options);
          },
        ),
      );
