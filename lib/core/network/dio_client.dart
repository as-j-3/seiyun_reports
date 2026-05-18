import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seiyun_reports_app/import.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://medicalhouse-ye.net/api/', // الرابط الأساسي للسيرفر
        connectTimeout: const Duration(seconds: 5), // وقت انتظار الاتصال
        receiveTimeout: const Duration(
          seconds: 5,
        ), // وقت انتظار استلام البيانات
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // إضافة (Interceptor) للتعامل مع التوكن (Token) تلقائياً في كل طلب
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            String? laravelToken = prefs.getString('access_token');

            if (laravelToken != null && laravelToken.isNotEmpty) {
              // إذا كان لدينا توكن من لارفيل، نستخدمه مباشرة
              options.headers['Authorization'] = 'Bearer $laravelToken';
            } else {
              // إذا لم يوجد توكن لارفيل، نحاول جلب توكن فيربيس (لأغراض تسجيل الدخول/الإنشاء)
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                String? firebaseToken = await user.getIdToken();
                if (firebaseToken != null) {
                  // نرسل توكن فيربيس في الهيدر كاحتياط
                  options.headers['Authorization'] = 'Bearer $firebaseToken';
                  
                  // إذا كان الطلب POST (مثل تسجيل الدخول)، نرسل التوكن في الجسم أيضاً
                  if (options.method == 'POST') {
                    if (options.data is FormData) {
                      (options.data as FormData).fields.add(MapEntry("idToken", firebaseToken));
                    } else if (options.data is Map) {
                      options.data['idToken'] = firebaseToken;
                    } else {
                      options.data = {"idToken": firebaseToken};
                    }
                  }
                }
              }
            }
          } catch (e) {
            debugPrint("Error in Dio Interceptor: $e");
          }
          return handler.next(options);
        },
      ),
    );
  }
}
