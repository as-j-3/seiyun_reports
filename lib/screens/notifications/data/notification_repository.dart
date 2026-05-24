import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// تحديث توكن FCM في السيرفر
  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      // جلب معرف الهوية من فيربيس (idToken) كما هو مطلوب في السيرفر
      User? user = FirebaseAuth.instance.currentUser;
      String? firebaseIdToken;
      if (user != null) {
        firebaseIdToken = await user.getIdToken();
      }

      final response = await _apiService.post(
        'update-fcm-token',
        data: {
          "idToken": firebaseIdToken, // إرسال توكن الفايربيس في الجسم
          "fcm_token": fcmToken, // إرسال توكن الإشعارات
        },
      );

      if (response.statusCode == 200 || response.statusCode == 210) {
        debugPrint("==========================================");
        debugPrint("🚀 [FCM SUCCESS] التوكن تم تحديثه بنجاح!");
        debugPrint("FCM Token: $fcmToken");
        debugPrint("==========================================");
        return true;
      }

      debugPrint("==========================================");
      debugPrint("❌ [FCM FAILURE] فشل تحديث التوكن في السيرفر");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("==========================================");
      return false;
    } catch (e) {
      debugPrint("==========================================");
      debugPrint("🚨 [FCM CRITICAL ERROR] خطأ غير متوقع أثناء المزامنة");
      debugPrint("Exception: $e");
      debugPrint("==========================================");
      return false;
    }
  }

  // يمكن إضافة دالة جلب قائمة الإشعارات هنا مستقبلاً
  // Future<List<AppNotification>> fetchNotifications() async { ... }
}
