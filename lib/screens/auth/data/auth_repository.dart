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
    String? name,
    String? token,
    String? email,
  }) async {

    final response = await _authService.login(
      role: role,
      name: name,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'];
      final userData = data['user'];
      final serverRole = data['role']?.toString() ?? 'citizens';
      final laravelToken = data['token']?.toString();

      // إنشاء موديل المستخدم مع دمج الدور من مستوى أعلى
      final userModel = UserModel(
        id: userData['id'],
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: serverRole,
      );

      await PrefHelper.saveLoginStatus(true);
      
      // حفظ التوكن القادم من لارفيل (مهم جداً للطلبات القادمة)
      if (laravelToken != null) {
        await PrefHelper.saveToken(laravelToken);
      }
      
      // حفظ الدور القادم من السيرفر
      await PrefHelper.saveRole(serverRole);

      // حفظ بيانات المستخدم في التخزين المحلي لجميع المستخدمين
      await PrefHelper.saveUserId(userModel.id);
      await PrefHelper.saveUserName(userModel.name);
      await PrefHelper.saveUserEmail(userModel.email);

      return userModel;
    } else {
      throw Exception('Server Error: ${response.data['message']}');
    }
  }
}

