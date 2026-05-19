
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
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
        _currentLocationName = (lat != null) ? 'لا توجد حاويات في منطقتك' : 'لا توجد حاويات قريبة حالياً';
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
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
