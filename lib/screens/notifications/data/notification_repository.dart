import 'package:flutter/foundation.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:seiyun_reports_app/screens/notifications/data/notification_database.dart';
import 'package:seiyun_reports_app/screens/notifications/models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// تحديث توكن FCM في السيرفر
  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      final response = await _apiService.post(
        'update-fcm-token',
        data: {"fcm_token": fcmToken},
      );

      if (response.statusCode == 200 || response.statusCode == 210) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }


  /// حفظ إشعار جديد في قاعدة البيانات المحلية
  Future<void> saveNotification(AppNotification notification) async {
    try {
      await NotificationDatabase.insertNotification(notification);
    } catch (e) {}
  }

  /// جلب كل الإشعارات المحفوظة لـ مستخدم معين
  Future<List<AppNotification>> loadNotifications(String userId) async {
    try {
      return await NotificationDatabase.getAllNotifications(userId);
    } catch (e) {
      return [];
    }
  }

  /// تعليم كل الإشعارات كـ مقروءة في قاعدة البيانات لمستخدم معين
  Future<void> markAllRead(String userId) async {
    try {
      await NotificationDatabase.markAllAsRead(userId);
    } catch (e) {}
  }

  /// حذف كل الإشعارات لمستخدم معين
  Future<void> clearAll(String userId) async {
    try {
      await NotificationDatabase.deleteForUser(userId);
    } catch (e) {}
  }
}
