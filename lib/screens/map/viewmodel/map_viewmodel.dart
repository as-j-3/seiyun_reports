import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      Icons.report_problem,
      Colors.orange,
      100,
    );
    reportIconProcessing = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.report_problem,
      Colors.blue,
      100,
    );
    reportIconSolved = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.check_circle_outline,
      Colors.green,
      100,
    );
    reportIconCancelled = await MapMarkerHelper.getMarkerIconFromIcon(
      Icons.cancel_outlined,
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
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: seiyunCenter, zoom: 14.0),
      ),
    );
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
    mapController = null;
    super.dispose();
  }
}
