import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';

class HomeViewModel extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  String _currentArea = 'جاري تحديد الموقع...';
  String get currentArea => _currentArea;

  HomeViewModel() {
    _fetchUser();
    _fetchLocation();
    FirebaseAuth.instance.userChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> _fetchLocation() async {
    _currentArea = await LocationService.getCurrentAreaName();
    notifyListeners();
  }

  void _fetchUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setPage(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // --- منطق البحث عن الخدمات ---
  String _serviceSearchQuery = "";
  String get serviceSearchQuery => _serviceSearchQuery;

  final List<Map<String, dynamic>> _allServices = [
    {'title': 'تقديم بلاغ جديد', 'icon': Icons.add_chart, 'page': 'report'},
    {'title': 'خريطة الحاويات', 'icon': Icons.map_outlined, 'page': 1},
    {'title': 'مواعيد رفع النفايات', 'icon': Icons.local_shipping_outlined, 'page': 'pickup'},
    {'title': 'أخبار وتحديثات سيئون', 'icon': Icons.newspaper, 'page': 2},
    {'title': 'الملف الشخصي', 'icon': Icons.person_outline, 'page': 3},
  ];

  void setServiceSearchQuery(String query) {
    _serviceSearchQuery = query;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredServices {
    if (_serviceSearchQuery.isEmpty) return [];
    return _allServices.where((s) => 
      s['title'].toString().toLowerCase().contains(_serviceSearchQuery.toLowerCase())
    ).toList();
  }
}
