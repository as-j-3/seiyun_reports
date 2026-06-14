import 'package:geolocator/geolocator.dart';

class LocationService {
  /// يطلب إذن الموقع من المستخدم
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// يجلب الإحداثيات الحالية للمستخدم
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// يجلب الموقع ويُعيد اسم المنطقة
  Future<String> getCurrentAreaName() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return 'موقعك غير محدد';

      return getAreaName(position.latitude, position.longitude);
    } catch (e) {
      return 'موقعك غير محدد';
    }
  }

  /// يحدد اسم المنطقة بناءً على الإحداثيات
  String getAreaName(double lat, double lng) {
    if (lat >= 15.85 && lat <= 16.05 && lng >= 48.70 && lng <= 48.90) {
      return 'سيئون';
    }
    if (lat >= 15.90 && lat <= 16.05 && lng >= 48.94 && lng <= 49.10) {
      return 'تريم';
    }
    if (lat >= 15.75 && lat <= 15.90 && lng >= 48.55 && lng <= 48.72) {
      return ' الغرفة';
    }
    if (lat >= 15.90 && lat <= 16.00 && lng >= 48.60 && lng <= 48.72) {
      return ' شبام';
    }
    if (lat >= 15.78 && lat <= 15.92 && lng >= 48.90 && lng <= 49.05) {
      return ' تاربة';
    }
    if (lat >= 15.55 && lat <= 15.75 && lng >= 48.80 && lng <= 49.05) {
      return ' دوعن';
    }

    return ' حضرموت';
  }
}
