import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends ChangeNotifier {
  static const LatLng seiyunCenter = LatLng(15.9429, 48.7844);
  GoogleMapController? mapController;

  bool _showReports = true;
  bool get showReports => _showReports;

  bool _showContainers = true;
  bool get showContainers => _showContainers;

  bool _isSatellite = false;
  bool get isSatellite => _isSatellite;

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

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
