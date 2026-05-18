import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seiyun_reports_app/screens/map/viewmodel/map_viewmodel.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({super.key, required this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation;
  GoogleMapController? _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _isMapReady = true; // الخريطة جاهزة فوراً لأننا لغينا الأنميشن
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحديد الموقع على الخريطة'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedLocation);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'حفظ الموقع',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_isMapReady)
              GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation.latitude == 0 ? MapViewModel.seiyunCenter : _selectedLocation,
                zoom: 16.0,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onTap: (location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation,
                  draggable: true,
                  onDragEnd: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            )
            else
              const Center(child: CircularProgressIndicator(color: Colors.green)),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'اضغط على الخريطة أو اسحب العلامة لتحديد موقع منزلك بدقة، ثم اضغط حفظ.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
