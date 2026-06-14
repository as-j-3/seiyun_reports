import 'package:flutter/foundation.dart';
import 'package:seiyun_reports_app/core/database/database_helper.dart';
import 'package:seiyun_reports_app/screens/notifications/models/notification_model.dart';

/// عمليات قاعدة البيانات المحلية للإشعارات المحدثة والآمنة من التصادم
class NotificationDatabase {
  static const _tableName = 'notifications';

  /// حفظ إشعار جديد في قاعدة البيانات بشكل آمن ومحمي
  static Future<void> insertNotification(AppNotification notification) async {
    try {
      final db = await DatabaseHelper().database;

      await db.transaction((txn) async {
        await txn.insert(
          _tableName,
          {
            'title': notification.title,
            'body': notification.body,
            'time': notification.time.toIso8601String(),
            'is_read': notification.isRead ? 1 : 0,
            'user_id': notification.userId,
          },
        );
      });
    } catch (e) {
    }
  }

  /// جلب كل الإشعارات لـ مستخدم معين (يشمل الإشعارات بدون userId كالتي ترد في الخلفية) مرتبة من الأحدث للأقدم
  static Future<List<AppNotification>> getAllNotifications(String userId) async {
    try {
      final db = await DatabaseHelper().database;
      final maps = await db.query(
        _tableName,
        where: 'user_id = ? OR user_id = ?',
        whereArgs: [userId, ''],
        orderBy: 'id DESC',
      );
      return maps.map((m) => AppNotification.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// تعليم كل الإشعارات كـ مقروءة لمستخدم معين
  static Future<void> markAllAsRead(String userId) async {
    try {
      final db = await DatabaseHelper().database;
      await db.update(
        _tableName,
        {'is_read': 1},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
    }
  }

  /// حذف كل الإشعارات لمستخدم معين
  static Future<void> deleteForUser(String userId) async {
    try {
      final db = await DatabaseHelper().database;
      await db.delete(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
    }
  }
}