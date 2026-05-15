import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            // جلب المستخدم الحالي من Firebase
            User? user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              // جلب الـ ID Token الخاص بالمستخدم لمصادقة الطلبات
              String? token = await user.getIdToken(true);

              if (token != null) {
                // إضافة التوكن في الـ Header للطلبات التي تستخدم Bearer Token
                options.headers['Authorization'] = 'Bearer $token';

                // إضافة التوكن كحقل idToken في طلبات الـ POST (بناءً على متطلبات السيرفر الحالي)
                if (options.method == 'POST') {
                  if (options.data is FormData) {
                    (options.data as FormData).fields.add(
                      MapEntry("idToken", token),
                    );
                  } else {
                    options.data = FormData.fromMap({
                      "idToken": token,
                      ...?options.data as Map<String, dynamic>?,
                    });
                  }
                }
              }
            }
          } catch (e) {
            debugPrint("خطأ في معترض الطلبات (Interceptor): $e");
          }
          return handler.next(options);
        },
      ),
    );
  }
}
