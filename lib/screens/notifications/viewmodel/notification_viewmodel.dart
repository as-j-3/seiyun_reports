import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  StreamSubscription<AppNotification>? _notificationSubscription;

  NotificationViewModel(this._repository, this._reportViewModel) {
    _init();
  }

  /// تهيئة خدمة الإشعارات وجلب التوكن والإشعارات المخزنة محلياً والتسمع للرسائل الجديدة
  Future<void> _init() async {
    await NotificationService.initialize();

    _token = await NotificationService.getToken();
    if (_token != null) {
      await _repository.updateFcmToken(_token!);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _token = newToken;
      _repository.updateFcmToken(newToken);
      notifyListeners();
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await loadNotificationsForUser(user.uid);
      } else {
        _notifications.clear();
        notifyListeners();
      }
    });

    _notificationSubscription = NotificationService.onNotificationSaved.listen(
      (notification) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null &&
            (notification.userId.isEmpty ||
                notification.userId == currentUser.uid)) {
          _notifications.insert(0, notification);
          _reportViewModel.fetchReportsFromLaravel(isRefresh: true);
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  /// تحميل الإشعارات لمستحدم معين
  Future<void> loadNotificationsForUser(String userId) async {
    final saved = await _repository.loadNotifications(userId);
    _notifications.clear();
    _notifications.addAll(saved);
    notifyListeners();
  }

  /// تعليم جميع الإشعارات كـ مقروءة وتحديث الواجهة
  Future<void> markAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || unreadCount == 0) return;
    await _repository.markAllRead(currentUser.uid);
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = AppNotification(
        id: _notifications[i].id,
        title: _notifications[i].title,
        body: _notifications[i].body,
        time: _notifications[i].time,
        isRead: true,
        userId: _notifications[i].userId,
      );
    }
    notifyListeners();
  }

  /// حذف جميع الإشعارات محلياً وتحديث الواجهة
  Future<void> clearAll() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    await _repository.clearAll(currentUser.uid);
    _notifications.clear();
    notifyListeners();
  }
}