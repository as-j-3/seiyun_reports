import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapZonesScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialTitle;

  const MapZonesScreen({Key? key, this.initialLocation, this.initialTitle}) : super(key: key);

  @override
  _MapZonesScreenState createState() => _MapZonesScreenState();
}

class _MapZonesScreenState extends State<MapZonesScreen> {
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _loadAllZones();
    
    // إذا تم تمرير موقع (مثل موقع بلاغ)، نقوم بإضافة مؤشر له
    if (widget.initialLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('report_location'),
          position: widget.initialLocation!,
          infoWindow: InfoWindow(title: widget.initialTitle ?? 'موقع البلاغ'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  // دالة لتحميل كافة الملفات
  Future<void> _loadAllZones() async {
    // 1. حدود سيئون (نجعلها بلون أزرق شفاف جداً لأنها تغطي كل الخريطة)
    await _loadGeoJson('json/boundary_sayun.json', isBoundary: true);
    
    // 2. مربعات الرفع
    await _loadGeoJson('json/upload_zones.json');
    
    // 3. مربعات الكنس
    await _loadGeoJson('json/sweep_zones.json');
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(200) + 55, // ألوان فاتحة
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
    );
  }

  // دالة قراءة الـ JSON وتحويله إلى Polygons
  Future<void> _loadGeoJson(String path, {bool isBoundary = false}) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> geoJson = jsonDecode(jsonString);

      final List<dynamic> features = geoJson['features'];
      Set<Polygon> newPolygons = {};

      for (var feature in features) {
        // التأكد أن الشكل عبارة عن مساحة (Polygon)
        if (feature['geometry']['type'] == 'Polygon') {
          // استخراج مصفوفة الإحداثيات
          final List<dynamic> coordinates = feature['geometry']['coordinates'][0];
          
          List<LatLng> polygonPoints = coordinates.map((coord) {
            // ملاحظة هامة: في الـ GeoJSON الترتيب يكون [خط الطول(lng), خط العرض(lat)]
            // بينما في Flutter الترتيب هو (lat, lng)
            return LatLng(coord[1], coord[0]);
          }).toList();

          // جلب اسم المنطقة إن وجد
          final String name = feature['properties']['Name'] ?? 'منطقة غير مسماة';
          
          final Color zoneColor = isBoundary ? Colors.blue : _getRandomColor();
          final Color fill = isBoundary ? zoneColor.withOpacity(0.05) : zoneColor.withOpacity(0.3);
          final Color stroke = isBoundary ? zoneColor.withOpacity(0.5) : zoneColor;

          newPolygons.add(
            Polygon(
              polygonId: PolygonId(name + path), // معرف فريد
              points: polygonPoints,
              fillColor: fill,
              strokeColor: stroke,
              strokeWidth: isBoundary ? 3 : 2,
              consumeTapEvents: true, // تفعيل إمكانية الضغط على المربع
              onTap: () {
                _showZoneDetails(name);
              },
            ),
          );
        }
      }

      // تحديث الخريطة بالبيانات الجديدة
      setState(() {
        _polygons.addAll(newPolygons);
      });
    } catch (e) {
      debugPrint('Error loading $path: $e');
    }
  }

  // إظهار تنبيه عند الضغط على المربع
  void _showZoneDetails(String name) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'المنطقة: $name',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'خريطة تقسيمات سيئون',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation ?? const LatLng(15.938833, 48.819307), 
          zoom: widget.initialLocation != null ? 16 : 13,
        ),
        polygons: _polygons,
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
