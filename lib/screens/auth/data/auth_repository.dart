import 'package:seiyun_reports_app/core/network/dio_client.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'auth_service.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  late AuthService _authService;

  AuthRepository() {
    final dioClient = DioClient();
    final apiService = ApiService(dioClient);
    _authService = AuthService(apiService);
  }

  Future<UserModel> registerUser({
    required String role,
    required String name,
    String? token,
    String? email,
  }) async {

    final response = await _authService.createUser(
      role: role,
      name: name,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final userModel = UserModel.fromJson(response.data['data']);

      await PrefHelper.saveLoginStatus(true);
      
      // حفظ التوكن والدور محلياً
      if (token != null) {
        await PrefHelper.saveToken(token);
      }
      
      // إذا كان الإيميل هو إيميل المشرف السحري، نقوم بحفظه كمشرف محلياً لضمان الدخول
      final finalRole = (email?.toLowerCase() == 'supervisor@app.com') ? 'supervisor' : userModel.role;
      await PrefHelper.saveRole(finalRole);

      await PrefHelper.saveUserId(userModel.id);
      await PrefHelper.saveUserName(userModel.name);

      return userModel;
    } else {
      throw Exception('Server Error: ${response.data['message']}');
    }
  }
}

