import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// خدمة الإشعارات المركزية للتطبيق بلمسات جمالية
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const Color _brandColor = Color(0xFF2E7D32); // اللون الأخضر الأساسي للتطبيق

  // ─── قناة إشعارات تغيير حالة البلاغ ───────────────────────────────────────
  static const _statusChannel = AndroidNotificationChannel(
    'report_status_channel',
    'تحديثات حالة البلاغ',
    description: 'إشعارات عند تغيير حالة البلاغ',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // ─── قناة إشعارات مواعيد الرفع ─────────────────────────────────────────────
  static const _pickupChannel = AndroidNotificationChannel(
    'pickup_reminder_channel',
    'تذكير مواعيد الرفع',
    description: 'إشعارات تنبه قبل موعد رفع النفايات',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  // ─── قناة الإشعارات العامة (FCM) ────────────────────────────────────────────
  static const _generalChannel = AndroidNotificationChannel(
    'reports_channel',
    'إشعارات البلاغات',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
  );

  static int _notifId = 0;
  static int get _nextId => ++_notifId;

  // ── التهيئة ──────────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ إذن الإشعارات ممنوح');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    await androidPlugin?.createNotificationChannel(_statusChannel);
    await androidPlugin?.createNotificationChannel(_pickupChannel);
    await androidPlugin?.createNotificationChannel(_generalChannel);

    FirebaseMessaging.onMessage.listen(_showFcmNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('📬 فُتح التطبيق من إشعار: ${msg.notification?.title}');
    });

    await _messaging.subscribeToTopic('all');
    await _messaging.subscribeToTopic('news');
  }

  // ── إشعار FCM العام ──────────────────────────────────────────────────────────
  static Future<void> _showFcmNotification(RemoteMessage message) async {
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
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  // ── إشعار تغيير حالة البلاغ (محسن) ─────────────────────────────────────────
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

  // ── إشعار فوري لموعد الرفع (محسن) ──────────────────────────────────────────
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
        color: Colors.orange, // لون مميز للتذكيرات
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          'موعد رفع النفايات $when ($date)\n⏱ من الساعة $startTime حتى $endTime\n📍 المناطق المشمولة: $locText',
          contentTitle: '🚛 تذكير: اقتراب موعد الرفع',
          summaryText: 'موعد الرفع',
        ),
      ),
    );
    await _localNotifications.show(
      _nextId,
      '🚛 تذكير: موعد رفع النفايات $when',
      'من $startTime حتى $endTime — $locText',
      details,
    );
  }

  // ── جدولة إشعار لموعد الرفع (محسن) ─────────────────────────────────────────
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

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  static Future<String?> getToken() async => _messaging.getToken();
}
