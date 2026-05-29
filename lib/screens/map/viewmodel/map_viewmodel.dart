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

  // Location tracking
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  double? _distanceToTarget;
  double? get distanceToTarget => _distanceToTarget;

  LatLng? _targetLocation;
  LatLng? get targetLocation => _targetLocation;

  bool _isIsolatedMode = false;
  bool get isIsolatedMode => _isIsolatedMode;

  // Custom Icons
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

  Future<void> fetchMapData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _mapData = await _repository.getMapData();
    } catch (e) {
      debugPrint("Error fetching map data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Location Tracking Methods
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

    // Get initial position
    _currentPosition = await Geolocator.getCurrentPosition();
    _calculateDistance();
    notifyListeners();
  }

  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _targetLocation = null;
    _isIsolatedMode = false;
    _distanceToTarget = null;
    notifyListeners();
  }

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

  void toggleReports() {
    _showReports = !_showReports;
    notifyListeners();
  }

  void toggleContainers() {
    _showContainers = !_showContainers;
    notifyListeners();
  }

  void toggleSatellite() {
    _isSatellite = !_isSatellite;
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

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

  void focusOnLocation(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 18.0),
      ),
    );
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

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
