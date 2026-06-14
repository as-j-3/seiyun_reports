import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:seiyun_reports_app/main.dart';

import '../../screens/notifications/data/notification_database.dart';
import '../../screens/notifications/models/notification_model.dart';

/// خدمة الإشعارات المركزية للتطبيق بلمسات جمالية
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final StreamController<AppNotification> _notificationController =
      StreamController<AppNotification>.broadcast();
  static Stream<AppNotification> get onNotificationSaved =>
      _notificationController.stream;

  static const Color _brandColor = Color(
    0xFF2E7D32,
  ); 

  static const _statusChannel = AndroidNotificationChannel(
    'report_status_channel',
    'تحديثات حالة البلاغ',
    description: 'إشعارات عند تغيير حالة البلاغ',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const _pickupChannel = AndroidNotificationChannel(
    'pickup_reminder_channel',
    'تذكير مواعيد الرفع',
    description: 'إشعارات تنبه قبل موعد رفع النفايات',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const _generalChannel = AndroidNotificationChannel(
    'reports_channel',
    'إشعارات البلاغات',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
  );

  static int _notifId = 0;
  static int get _nextId => ++_notifId;

  /// تهيئة وإعداد خدمة الإشعارات وتراخيص التطبيق والقنوات الخاصة بها
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
      },
    );

    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(_statusChannel);
    await androidPlugin?.createNotificationChannel(_pickupChannel);
    await androidPlugin?.createNotificationChannel(_generalChannel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_showFcmNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handleNotificationClick(msg);
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }

    await _messaging.subscribeToTopic('all');
    await _messaging.subscribeToTopic('news');
  }

  /// معالجة الحدث عند نقر المستخدم على الإشعار بالانتقال إلى شاشة الإشعارات
  static void _handleNotificationClick(RemoteMessage message) {

    final context = MyApp.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed('/notifications');
    }
  }

  /// عرض إشعار محلي وتخزينه في قاعدة البيانات عند استقبال رسالة FCM
  static Future<void> _showFcmNotification(RemoteMessage message) async {
    if (message.notification != null) {
      final String title = message.notification!.title ?? "تنبيه جديد";
      final String body = message.notification!.body ?? "";

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _generalChannel.id,
          _generalChannel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _brandColor,
        ),
      );
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        details,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final notification = AppNotification(
        title: title,
        body: body,
        time: DateTime.now(),
        userId: userId,
      );

      try {
        await NotificationDatabase.insertNotification(notification);
        _notificationController.add(notification);
      } catch (e) {
        debugPrint('Foreground notification save error: $e');
      }
    }
  }

  /// عرض إشعار محلي للمستخدم يفيد بتحديث حالة البلاغ الخاص به
  static Future<void> showStatusChangedNotification({
    required String reportTitle,
    required String oldStatus,
    required String newStatus,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _statusChannel.id,
        _statusChannel.name,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: _brandColor,
        enableLights: true,
        ledColor: _brandColor,
        ledOnMs: 1000,
        ledOffMs: 500,
        styleInformation: BigTextStyleInformation(
          'تغيرت حالة بلاغ "$reportTitle" بنجاح\nالحالة السابقة: $oldStatus\nالحالة الجديدة: $newStatus',
          contentTitle: '✅ تحديث في حالة بلاغك',
          summaryText: 'تحديث البلاغ',
        ),
      ),
    );
    await _localNotifications.show(
      _nextId,
      '🔔 تحديث حالة البلاغ',
      'تم تغيير الحالة إلى: $newStatus',
      details,
    );
  }

  /// عرض إشعار تذكيري بموعد رفع النفايات والمناطق المشمولة
  static Future<void> showPickupReminderNotification({
    required String day,
    required String date,
    required String startTime,
    required String endTime,
    required List<String> locations,
    bool isToday = false,
  }) async {
    final when = isToday ? 'اليوم' : 'غداً ($day)';
    final locText = locations.join('، ');

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _pickupChannel.id,
        _pickupChannel.name,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: Colors.orange, 
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          'موعد رفع النفايات $when ($date)\n⏱ من الساعة $startTime حتى $endTime\n المناطق المشمولة: $locText',
          contentTitle: ' تذكير: اقتراب موعد الرفع',
          summaryText: 'موعد الرفع',
        ),
      ),
    );
    await _localNotifications.show(
      _nextId,
      ' تذكير: موعد رفع النفايات $when',
      'من $startTime حتى $endTime — $locText',
      details,
    );
  }

  /// جدولة إشعار تذكيري بموعد الرفع في وقت وتاريخ محددين
  static Future<void> schedulePickupNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _pickupChannel.id,
          _pickupChannel.name,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: _brandColor,
          enableLights: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// إلغاء كافة الإشعارات المجدولة والنشطة في التطبيق
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// جلب رمز الـ Token الخاص بالجهاز لإرسال الإشعارات المستهدفة
  static Future<String?> getToken() async => _messaging.getToken();

  /// تحرير الموارد عند إيقاف الخدمة
  static void dispose() {
    _notificationController.close();
  }
}

/// معالج الإشعارات في الخلفية (يعمل في isolate منفصل)
/// يُسجل عبر FirebaseMessaging.onBackgroundMessage لحفظ الإشعارات عند وصولها والتطبيق في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    final String title = message.notification!.title ?? "تنبيه جديد";
    final String body = message.notification!.body ?? "";

    try {
      await NotificationDatabase.insertNotification(
        AppNotification(
          title: title,
          body: body,
          time: DateTime.now(),
          userId: '',
        ),
      );
    } catch (e) {
      debugPrint('Background notification save error: $e');
    }
  }
}
