import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import 'package:seiyun_reports_app/core/services/notification_service.dart';
import '../models/pickup_schedule_model.dart';


class PickupSchedulesViewModel extends ChangeNotifier {
  List<PickupScheduleModel> _schedules = [];
  List<PickupScheduleModel> get schedules => _schedules;

  List<NearbyContainerModel> _nearbyContainers = [];
  List<NearbyContainerModel> get nearbyContainers => _nearbyContainers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentLocationName = 'جاري تحديد الموقع...';
  String get currentLocationName => _currentLocationName;

  PickupSchedulesViewModel() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    _isLoading = true;
    notifyListeners();

    // Fetch actual location
    try {
      final area = await LocationService.getCurrentAreaName();
      _currentLocationName = area;
    } catch (e) {
      _currentLocationName = 'موقعك غير محدد';
    }

    // Mocking Laravel API response
    await Future.delayed(const Duration(milliseconds: 800));

    _schedules = [
      PickupScheduleModel(
        id: '1',
        day: 'السبت',
        date: '27 نوفمبر',
        startTime: '05:00',
        endTime: '07:00',
        locations: ['مريمة - المعسكر', 'مريمة - عصيران'],
        isTomorrow: true,
      ),
      PickupScheduleModel(
        id: '2',
        day: 'الأحد',
        date: '28 نوفمبر',
        startTime: '05:00',
        endTime: '07:00',
        locations: ['مريمة - المقبرة', 'مريمة - الخضراء'],
      ),
      PickupScheduleModel(
        id: '3',
        day: 'الإثنين',
        date: '29 نوفمبر',
        startTime: '05:00',
        endTime: '07:00',
        locations: ['مريمة - المقبرة', 'مريمة - الخضراء'],
      ),
    ];

    _nearbyContainers = [
      NearbyContainerModel(
        id: '15',
        locationName: 'حاوية المسجد القريبة جداً',
        nameStreet: 'شارع تجريبي 1',
        classification: 'رئيسي',
        distance: '110 متر',
        walkingTime: '2 دقيقة مشياً',
        areaName: 'السحيل',
        period: 'مسائية',
        areaStartTime: '05:00 AM',
        areaEndTime: '07:00 AM',
        statusText: 'هدأ',
        collectionDay: 'الثلاثاء و الاثنين',
        latitude: 15.9429,
        longitude: 48.7844,
      ),
      NearbyContainerModel(
        id: '16',
        locationName: 'حاوية حي السحيل',
        nameStreet: 'السحيل الغربية - بجانب مسجد الفتح',
        classification: 'فرعي',
        distance: '50 متر',
        walkingTime: '1 دقيقة مشياً',
        areaName: 'السحيل',
        period: 'صباحية',
        areaStartTime: '08:00 AM',
        areaEndTime: '10:00 AM',
        statusText: 'ممتلئة',
        collectionDay: 'الأحد و الأربعاء',
        latitude: 15.9400,
        longitude: 48.7800,
      ),
    ];

    _isLoading = false;
    notifyListeners();

    // ── إطلاق وجدولة إشعارات مواعيد الرفع ──────────────────────────────────
    _managePickupNotifications();
  }

  /// يدير الإشعارات الفورية والمجدولة
  Future<void> _managePickupNotifications() async {
    // إلغاء الإشعارات المجدولة القديمة لتجنب التكرار
    await NotificationService.cancelAllNotifications();

    for (final schedule in _schedules) {
      // 1. إشعار فوري إذا كان الموعد اليوم أو غداً (تنبيه عند فتح التطبيق)
      if (schedule.isToday || schedule.isTomorrow) {
        NotificationService.showPickupReminderNotification(
          day: schedule.day,
          date: schedule.date,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          locations: schedule.locations,
          isToday: schedule.isToday,
        );
      }

      // 2. جدولة إشعار مستقبلي إذا كان الموعد غداً (مثلاً قبل الموعد بـ 30 دقيقة)
      if (schedule.isTomorrow) {
        _scheduleFuturePickup(schedule);
      }
    }
  }

  void _scheduleFuturePickup(PickupScheduleModel schedule) {
    try {
      // استخراج الوقت (نفترض تنسيق HH:mm مثل 05:00)
      final parts = schedule.startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // حساب وقت الإشعار: غداً في نفس وقت البداية (أو قبله بمدة)
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      ).subtract(const Duration(minutes: 30)); // تنبيه قبل الموعد بـ 30 دقيقة

      // إذا كان الوقت المحسوب قد مضى فعلاً اليوم (في حال كان الوقت مبكراً جداً)
      if (scheduledDate.isBefore(now)) return;

      NotificationService.schedulePickupNotification(
        id: int.tryParse(schedule.id) ?? 100 + schedule.hashCode,
        title: '🚛 تذكير: موعد الرفع يقترب',
        body: 'سيبدأ رفع النفايات في ${schedule.startTime} في مناطق: ${schedule.locations.take(2).join(", ")}',
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      debugPrint('⚠️ خطأ في جدولة الإشعار: $e');
    }
  }

  int get totalNearbyContainers => _nearbyContainers.length;
}
