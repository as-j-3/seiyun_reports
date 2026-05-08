import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:seiyun_reports_app/core/services/notification_service.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

class NotificationViewModel extends ChangeNotifier {
  String? _token;
  String? get token => _token;

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationViewModel() {
    _init();
  }

  Future<void> _init() async {
    await NotificationService.initialize();
    _token = await NotificationService.getToken();
    debugPrint("======== FCM TOKEN ========");
    debugPrint(_token ?? "Failed to get token");
    debugPrint("===========================");
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _addNotification(
          message.notification!.title ?? "تنبيه جديد",
          message.notification!.body ?? "",
        );
      }
    });

    notifyListeners();
    if (_token != null) {
      await _sendTokenToServer(_token!);
    }
  }

  void _addNotification(String title, String body) {
    _notifications.insert(0, AppNotification(
      title: title,
      body: body,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void markAsRead() {
    if (unreadCount == 0) return;
    
    // منطق بسيط لتعليم الكل كمقروء عند فتح القائمة
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = AppNotification(
        title: _notifications[i].title,
        body: _notifications[i].body,
        time: _notifications[i].time,
        isRead: true,
      );
    }
    notifyListeners();
  }

  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      // تم الاحتفاظ بالكود القديم للتواصل مع السيرفر
      await http.post(
        Uri.parse("https://60e573cbec47e8.lhr.life/api/update-fcm-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fcm_token": fcmToken}),
      );
    } catch (e) {
      debugPrint("خطأ في تحديث التوكن بالسيرفر: $e");
    }
  }
}
