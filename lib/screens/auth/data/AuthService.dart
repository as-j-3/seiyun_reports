import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Response> createUser({
    required String role,
    required String name,
  }) async {
    return await _apiService.post(
      '/createUser',
      data: { 'role': role, 'name': name},
    );
  }
}
