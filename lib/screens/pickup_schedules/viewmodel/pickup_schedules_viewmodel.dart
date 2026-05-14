import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
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
  }

  int get totalNearbyContainers => _nearbyContainers.length;
}
