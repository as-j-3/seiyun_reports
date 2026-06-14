import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import '../models/home_data_model.dart';
import '../data/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;
  final LocationService _locationService;
  Timer? _autoRefreshTimer;

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

  /// تغيير الصفحة الحالية في واجهة المستخدم وتحديث الموقع
  void setPage(int index) {
    _currentIndex = index;
    _fetchLocation(); 
    notifyListeners();
  }

  int _reportActive = 0;
  int get reportActive => _reportActive;

  int _reportSolved = 0;
  int get reportSolved => _reportSolved;

  List<RecentReportModel> _recentReports = [];
  List<RecentReportModel> get recentReports => _recentReports;

  HomeViewModel(this._repository, this._locationService) {
    _fetchUser();
    _fetchLocation();
    _fetchHomeData();
    _startAutoRefresh();
    FirebaseAuth.instance.userChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _fetchHomeData();
      }
      notifyListeners();
    });
  }

  /// بدء مؤقت التحديث التلقائي لبيانات الصفحة الرئيسية
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      refreshData();
    });
  }

  /// تحديث كافة بيانات الصفحة الرئيسية من الخادم والموقع
  Future<void> refreshData() async {
    await _fetchUser();
    await _fetchHomeData();
    await _fetchLocation();
  }

  /// جلب بيانات المستخدم الحالي واسمه المخزن محلياً
  Future<void> _fetchUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    _userName = await PrefHelper.getUserName() ?? 'مستخدم';
    notifyListeners();
  }

  /// جلب اسم المنطقة الحالية للمستخدم
  Future<void> _fetchLocation() async {
    final savedAddress = await PrefHelper.getUserAddress();
    if (savedAddress != null && savedAddress.isNotEmpty) {
      _currentArea = savedAddress;
    } else {
      _currentArea = await _locationService.getCurrentAreaName();
    }
    notifyListeners();
  }

  /// جلب بيانات اللوحة الرئيسية (الإحصائيات، البلاغات الأخيرة) من المستودع
  Future<void> _fetchHomeData() async {
    try {
      final data = await _repository.getHomeData();
      if (data != null) {
        _nextCollection = data.nextCollection;
        _reportActive = data.reportActive;
        _reportSolved = data.reportSolved;
        _recentReports = data.reports;
        if (data.userName.isNotEmpty) {
          _userName = data.userName;
        }
        notifyListeners();
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  String _serviceSearchQuery = "";
  String get serviceSearchQuery => _serviceSearchQuery;

  final List<Map<String, dynamic>> _allServices = [
    {'title': 'تقديم بلاغ جديد', 'icon': Icons.add_chart, 'page': 'report'},
    {'title': 'خريطة الحاويات', 'icon': Icons.map_outlined, 'page': 1},
    {
      'title': 'مواعيد رفع النفايات',
      'icon': Icons.local_shipping_outlined,
      'page': 'pickup',
    },
    {'title': 'أخبار وتحديثات سيئون', 'icon': Icons.newspaper, 'page': 2},
    {'title': 'الملف الشخصي', 'icon': Icons.person_outline, 'page': 3},
  ];

  /// تعيين نص البحث الخاص بالخدمات
  void setServiceSearchQuery(String query) {
    _serviceSearchQuery = query;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredServices {
    if (_serviceSearchQuery.isEmpty) return [];
    return _allServices
        .where(
          (s) => s['title'].toString().toLowerCase().contains(
            _serviceSearchQuery.toLowerCase(),
          ),
        )
        .toList();
  }
}
