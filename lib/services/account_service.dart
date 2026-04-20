import 'package:dio/dio.dart';

import '../models/account.dart';
import 'dio_client.dart';

class AccountService {
  static Future<Account> getAccount() async {
    try {
      final response = await dio.get('/account');
      return Account.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch account: ${e.message}');
    }
  }
}
