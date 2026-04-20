import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_token.dart';
import '../models/login_request.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class AuthNotifier extends AsyncNotifier<AuthToken?> {
  final _authService = AuthService();

  @override
  Future<AuthToken?> build() async {
    // Check for existing token on app start
    final token = await StorageService.readToken();
    if (token == null) return null;
    return AuthToken(token: token);
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final token = await _authService.login(
          LoginRequest(username: username, password: password),
        );
        await StorageService.writeToken(token.token);
        return token;
      } catch (e) {
        //remove
        print('Login error: ${e}');
        rethrow;
      }
    });
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthToken?>(
  AuthNotifier.new,
);
