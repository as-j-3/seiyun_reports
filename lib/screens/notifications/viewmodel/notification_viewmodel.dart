import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:seiyun_reports_app/core/services/notification_service.dart';
import 'package:seiyun_reports_app/screens/notifications/data/notification_repository.dart';
import 'package:seiyun_reports_app/screens/notifications/models/notification_model.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  final ReportViewModel _reportViewModel;

  String? _token;
  String? get token => _token;

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationViewModel(this._repository, this._reportViewModel) {
    _init();
  }

  Future<void> _init() async {
    // 1. تهيئة خدمة الإشعارات (Firebase + Local Notifications)
    await NotificationService.initialize();

    // 2. جلب وتحديث التوكن بالسيرفر
    _token = await NotificationService.getToken();
    debugPrint("======== FCM TOKEN ========");
    debugPrint(_token ?? "Failed to get token");
    debugPrint("===========================");

    if (_token != null) {
      await _repository.updateFcmToken(_token!);
    }

    // 3. التسمع لتجدد التوكن تلقائياً
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _token = newToken;
      _repository.updateFcmToken(newToken);
      notifyListeners();
    });

    // 4. التسمع للإشعارات والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String title = message.notification!.title ?? "تنبيه جديد";
        String body = message.notification!.body ?? "";

        // أ. إضافة الإشعار للقائمة في الـ UI
        _addNotification(title, body);

        // ب. تحديث البلاغات تلقائياً (Silent Sync) لضمان تزامن البيانات
        _reportViewModel.fetchReportsFromLaravel(isRefresh: true);

        debugPrint(
          "🔔 Foreground Notification received: $title. Triggering silent sync.",
        );
      }
    });

    notifyListeners();
  }

  void _addNotification(String title, String body) {
    _notifications.insert(
      0,
      AppNotification(title: title, body: body, time: DateTime.now()),
    );
    notifyListeners();
  }

  void markAsRead() {
    if (unreadCount == 0) return;

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
}
