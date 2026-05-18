import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Response> login({
    required String role,
    String? name,
  }) async {
    return await _apiService.post(
      '/login',
      data: { 
        'role': role, 
        if (name != null) 'name': name,
        // ملاحظة: التوكن (idToken) يتم إضافته تلقائياً بواسطة DioClient Interceptor
      },
    );
  }
}
