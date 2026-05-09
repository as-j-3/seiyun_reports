import 'package:flutter/material.dart';
import '../models/pickup_schedule_model.dart';

class PickupSchedulesViewModel extends ChangeNotifier {
  List<PickupScheduleModel> _schedules = [];
  List<PickupScheduleModel> get schedules => _schedules;

  List<NearbyContainerModel> _nearbyContainers = [];
  List<NearbyContainerModel> get nearbyContainers => _nearbyContainers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PickupSchedulesViewModel() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    _isLoading = true;
    notifyListeners();

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
        id: 'c1',
        name: 'حاوية شارع الجزائر',
        address: 'شارع الجزائر - بجانب مسجد النور',
        distance: 30,
        status: 'full',
        latitude: 15.9429,
        longitude: 48.7844,
      ),
      NearbyContainerModel(
        id: 'c2',
        name: 'حاوية حي السحيل',
        address: 'السحيل الغربية - بجانب مسجد الفتح',
        distance: 50,
        status: 'half',
        latitude: 15.9400,
        longitude: 48.7800,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  int get totalNearbyContainers => _nearbyContainers.length;
}
