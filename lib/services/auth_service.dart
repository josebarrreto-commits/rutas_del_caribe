
import 'api_service.dart';

class AuthService {
  AuthService(this.api);

  final ApiService api;

  Future<dynamic> login({
    required String username,
    required String password,
  }) {
    return api.post('/auth/login', {
      'username': username,
      'password': password,
    });
  }

  Future<dynamic> changePassword({
    required String nuevaPassword,
    required String confirmacionPassword,
  }) {
    return api.post('/auth/cambiar-password', {
      'nuevaPassword': nuevaPassword,
      'confirmacionPassword': confirmacionPassword,
    });
  }
}
