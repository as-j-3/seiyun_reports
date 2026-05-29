import 'package:flutter/foundation.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// تحديث توكن FCM في السيرفر
  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      final response = await _apiService.post(
        'update-fcm-token',
        data: {
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
