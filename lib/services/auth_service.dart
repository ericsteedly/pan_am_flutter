import '../models/auth_token.dart';
import '../models/login_request.dart';
import 'dio_client.dart';

class AuthService {
  Future<AuthToken> login(LoginRequest request) async {
    final response = await dio.post(
      '/login',
      data: request.toJson(),
    );
    return AuthToken.fromJson(response.data);
  }
}
