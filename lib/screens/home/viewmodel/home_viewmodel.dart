
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import '../models/home_data_model.dart';
import '../data/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;
  final LocationService _locationService;

  User? _currentUser;
  User? get currentUser => _currentUser;

  NextCollectionModel? _nextCollection;
  NextCollectionModel? get nextCollection => _nextCollection;

  String _currentArea = 'جاري تحديد الموقع...';
  String get currentArea => _currentArea;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  String _userName = 'مستخدم';
  String get userName => _userName;

  void setPage(int index) {
    _currentIndex = index;
    _fetchLocation(); // تحديث الموقع عند التبديل بين الصفحات
    notifyListeners();
  }

  HomeViewModel(this._repository, this._locationService) {
    _fetchUser();
    _fetchLocation();
    _fetchNextCollection();
    FirebaseAuth.instance.userChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _fetchNextCollection();
      }
      notifyListeners();
    });
  }

  Future<void> refreshData() async {
    await _fetchUser();
    await _fetchNextCollection();
    await _fetchLocation();
  }

  Future<void> _fetchUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    _userName = await PrefHelper.getUserName() ?? 'مستخدم';
    notifyListeners();
  }

  Future<void> _fetchLocation() async {
    final savedAddress = await PrefHelper.getUserAddress();
    if (savedAddress != null && savedAddress.isNotEmpty) {
      _currentArea = savedAddress;
    } else {
      _currentArea = await _locationService.getCurrentAreaName();
    }
    notifyListeners();
  }

  Future<void> _fetchNextCollection() async {
    try {
      final data = await _repository.getHomeData();
      if (data != null) {
        _nextCollection = data.nextCollection;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching next collection: $e");
    }
  }
}
