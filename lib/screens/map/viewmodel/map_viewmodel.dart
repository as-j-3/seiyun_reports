import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../data/map_repository.dart';
import '../models/map_data_model.dart';
import '../utils/map_marker_helper.dart';

class MapViewModel extends ChangeNotifier {
  final MapRepository _repository;
  static const LatLng seiyunCenter = LatLng(15.9429, 48.7844);
  GoogleMapController? mapController;

  MapDataModel? _mapData;
  MapDataModel? get mapData => _mapData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  double? _distanceToTarget;
  double? get distanceToTarget => _distanceToTarget;

  LatLng? _targetLocation;
  LatLng? get targetLocation => _targetLocation;

  bool _isIsolatedMode = false;
  bool get isIsolatedMode => _isIsolatedMode;

  BitmapDescriptor? reportIconPending;
  BitmapDescriptor? reportIconProcessing;
  BitmapDescriptor? reportIconSolved;
  BitmapDescriptor? reportIconCancelled;
  BitmapDescriptor? containerIcon;

  bool _showReports = true;
  bool get showReports => _showReports;

  bool _showContainers = true;
  bool get showContainers => _showContainers;

  bool _isSatellite = false;
  bool get isSatellite => _isSatellite;

  MapViewModel(this._repository) {
    _loadIcons().then((_) => fetchMapData());
  }

  /// تحميل وتخصيص أيقونات العلامات (الماركرز) على الخريطة
  Future<void> _loadIcons() async {
    containerIcon = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.delete_outline,
      Colors.green,
      100,
    );
    reportIconPending = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.report_problem_outlined,
      Colors.orange,
      100,
    );
    reportIconProcessing = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.report_problem_outlined,
      Colors.blue,
      100,
    );
    reportIconSolved = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.report_problem_outlined,
      Colors.green,
      100,
    );
    reportIconCancelled = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.report_problem_outlined,
      Colors.red,
      100,
    );
    notifyListeners();
  }

  /// جلب بيانات الخريطة (الحاويات والبلاغات) من المستودع
  Future<void> fetchMapData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _mapData = await _repository.getMapData();
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// بدء تتبع موقع المستخدم الحالي وحساب المسافة إلى موقع مستهدف
  Future<void> startLocationTracking(LatLng? target) async {
    _targetLocation = target;
    _isIsolatedMode = target != null;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _calculateDistance();
      notifyListeners();
    });

    _currentPosition = await Geolocator.getCurrentPosition();
    _calculateDistance();
    notifyListeners();
  }

  /// إيقاف تتبع موقع المستخدم وتصفير البيانات المتعلقة به
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _targetLocation = null;
    _isIsolatedMode = false;
    _distanceToTarget = null;
    notifyListeners();
  }

  /// حساب المسافة بين موقع المستخدم الحالي والموقع المستهدف
  void _calculateDistance() {
    if (_currentPosition != null && _targetLocation != null) {
      _distanceToTarget = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _targetLocation!.latitude,
        _targetLocation!.longitude,
      );
    }
  }

  /// إظهار أو إخفاء البلاغات على الخريطة
  void toggleReports() {
    _showReports = !_showReports;
    notifyListeners();
  }

  /// إظهار أو إخفاء الحاويات على الخريطة
  void toggleContainers() {
    _showContainers = !_showContainers;
    notifyListeners();
  }

  /// التبديل بين العرض العادي وعرض القمر الصناعي للخريطة
  void toggleSatellite() {
    _isSatellite = !_isSatellite;
    notifyListeners();
  }

  /// تهيئة متحكم الخريطة عند إنشائها
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// تحريك الكاميرا إلى موقع المستخدم الحالي أو إلى مركز سيئون
  void moveToCenter() {
    if (_currentPosition != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 17.0,
          ),
        ),
      );
    } else {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: seiyunCenter, zoom: 14.0),
        ),
      );
    }
  }

  /// التركيز وتقريب الكاميرا على موقع محدد على الخريطة
  void focusOnLocation(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 18.0),
      ),
    );
  }

  /// تكبير مستوى الرؤية (الزوم) في الخريطة
  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  /// تصغير مستوى الرؤية (الزوم) في الخريطة
  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    mapController = null;
    super.dispose();
  }
}
