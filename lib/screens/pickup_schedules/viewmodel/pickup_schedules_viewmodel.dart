import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import 'package:seiyun_reports_app/core/services/notification_service.dart';
import '../models/pickup_schedule_model.dart';
import '../data/pickup_schedules_repository.dart';

class PickupSchedulesViewModel extends ChangeNotifier {
  final PickupSchedulesRepository _repository;
  final LocationService _locationService;
  Timer? _autoRefreshTimer;

  List<PickupScheduleModel> _containers = [];
  List<PickupScheduleModel> get containers => _containers;

  // Getters للتوافق مع الواجهة الحالية وإصلاح الأخطاء
  List<PickupScheduleModel> get nearbyContainers => _containers;
  List<PickupScheduleModel> get schedules => _containers;
  int get totalNearbyContainers => _containers.length;

  String get nextPickupDayLabel {
    if (_containers.isEmpty) return '-';
    final next = _containers.first;
    if (next.status.isNotEmpty) return next.status;
    return next.day;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentLocationName = 'جاري تحديد الموقع...';
  String get currentLocationName => _currentLocationName;

  PickupSchedulesViewModel(this._repository, this._locationService) {
    fetchData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchData(showLoading: false);
    });
  }

  Future<void> fetchData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // 1. محاولة الحصول على الموقع المحفوظ من البروفايل أولاً
      double? lat = await PrefHelper.getUserLat();
      double? lng = await PrefHelper.getUserLng();

      if (lat != null && lng != null) {
        // استخدام الموقع المحفوظ
        _containers = await _repository.fetchNearbyContainers(lat, lng);
      } else {
        // 2. إذا لم يوجد موقع محفوظ، تحديد موقع المستخدم الحالي عبر GPS
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          _containers = await _repository.fetchNearbyContainers(
            position.latitude,
            position.longitude,
          );
        }
      }

      final savedAddress = await PrefHelper.getUserAddress();
      if (savedAddress != null && savedAddress.isNotEmpty) {
        _currentLocationName = savedAddress;
      } else if (_containers.isNotEmpty) {
        _currentLocationName = _containers.first.areaName;
      } else {
        _currentLocationName =
            (lat != null)
                ? 'لا توجد حاويات في منطقتك'
                : 'لا توجد حاويات قريبة حالياً';
      }
    } catch (e) {
      print("Error fetching pickup schedules: $e");
      _currentLocationName = 'حدث خطأ أثناء جلب البيانات';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }

    // ── إطلاق وجدولة إشعارات مواعيد الرفع ──────────────────────────────────
    _managePickupNotifications();
  }

  /// يدير الإشعارات الفورية والمجدولة
  Future<void> _managePickupNotifications() async {
    // إلغاء الإشعارات المجدولة القديمة لتجنب التكرار
    await NotificationService.cancelAllNotifications();

    for (final schedule in containers) {
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
        id: schedule.id,
        title: ' تذكير: موعد الرفع يقترب',
        body:
            'سيبدأ رفع النفايات في ${schedule.startTime} في مناطق: ${schedule.locations.take(2).join(", ")}',
        scheduledDate: scheduledDate,
      );
    } catch (e) {
      debugPrint('⚠️ خطأ في جدولة الإشعار: $e');
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
