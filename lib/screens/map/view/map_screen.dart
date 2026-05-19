import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/viewmodel/citizen_reports_viewmodel.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/viewmodel/pickup_schedules_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/viewmodel/map_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/view/widgets/map_filter_chip.dart';
import 'package:seiyun_reports_app/screens/map/view/widgets/map_info_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialTitle;
  final bool isPicker;

  const MapScreen({
    super.key,
    this.initialLocation,
    this.initialTitle,
    this.isPicker = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.isPicker &&
        widget.initialLocation != null &&
        widget.initialLocation!.latitude != 0) {
      _pickedLocation = widget.initialLocation;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().fetchMapData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();

    final Set<Marker> markers = _buildMarkers(context, mapVM);

    // Add temporary marker for initial location if provided (not in picker mode)
    if (!widget.isPicker && widget.initialLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('initial_focus'),
          position: widget.initialLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.initialTitle ?? 'موقع البلاغ'),
        ),
      );
    }

    // Add marker for picker mode
    if (widget.isPicker && _pickedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('picked_location'),
          position: _pickedLocation!,
          draggable: true,
          onDragEnd: (location) {
            setState(() {
              _pickedLocation = location;
            });
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPicker ? 'تحديد الموقع على الخريطة' : 'خريطة سيئون',
        ),
        actions:
            widget.isPicker
                ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _pickedLocation);
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
                        'حفظ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'تحديث',
                    onPressed: () => mapVM.fetchMapData(),
                  ),
                  IconButton(
                    icon: Icon(
                      mapVM.isSatellite
                          ? Icons.map_outlined
                          : Icons.satellite_alt_outlined,
                    ),
                    tooltip:
                        mapVM.isSatellite
                            ? 'العرض العادي'
                            : 'عرض القمر الصناعي',
                    onPressed: () => mapVM.toggleSatellite(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    tooltip: 'موقعي',
                    onPressed: () => mapVM.moveToCenter(),
                  ),
                ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapVM.onMapCreated(controller);
              if (widget.initialLocation != null) {
                // Focus on the location after a short delay to ensure map is ready
                Future.delayed(const Duration(milliseconds: 500), () {
                  mapVM.focusOnLocation(widget.initialLocation!);
                });
              }
            },
            initialCameraPosition: CameraPosition(
              target:
                  widget.initialLocation != null &&
                          widget.initialLocation!.latitude != 0
                      ? widget.initialLocation!
                      : MapViewModel.seiyunCenter,
              zoom:
                  widget.initialLocation != null &&
                          widget.initialLocation!.latitude != 0
                      ? 17.0
                      : 14.0,
            ),
            mapType: mapVM.isSatellite ? MapType.satellite : MapType.normal,
            markers: markers,
            onTap:
                widget.isPicker
                    ? (location) {
                      setState(() {
                        _pickedLocation = location;
                      });
                    }
                    : null,
            myLocationEnabled: true,
            myLocationButtonEnabled: widget.isPicker,
            zoomControlsEnabled: false,
          ),
          // Legend / Filters
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  MapFilterChip(
                    label: 'بلاغات المواطنين',
                    color: Colors.blue,
                    icon: Icons.report_problem_outlined,
                    isSelected: mapVM.showReports,
                    onTap: () => mapVM.toggleReports(),
                  ),
                  const SizedBox(width: 8),
                  MapFilterChip(
                    label: 'حاويات النفايات',
                    color: AppTheme.primaryGreen,
                    icon: Icons.delete_outline,
                    isSelected: mapVM.showContainers,
                    onTap: () => mapVM.toggleContainers(),
                  ),
                ],
              ),
            ),
          ),
          // Info box for picker mode
          if (widget.isPicker)
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
          // Zoom Controls
          Positioned(
            right: 12,
            bottom: 180,
            child: Column(
              children: [
                _ZoomButton(icon: Icons.add, onPressed: () => mapVM.zoomIn()),
                const SizedBox(height: 4),
                _ZoomButton(
                  icon: Icons.remove,
                  onPressed: () => mapVM.zoomOut(),
                ),
              ],
            ),
          ),
          if (mapVM.isLoading && !widget.isPicker)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(BuildContext context, MapViewModel mapVM) {
    final Set<Marker> markers = {};
    final data = mapVM.mapData;

    if (data == null) return markers;

    // Add Report Markers
    if (mapVM.showReports) {
      for (var report in data.reports) {
        if (report.lat == 0.0 || report.lng == 0.0) continue;

        double hue;
        switch (report.status) {
          case 'تم الحل':
            hue = BitmapDescriptor.hueGreen;
            break;
          case 'قيد المعالجة':
            hue = BitmapDescriptor.hueAzure;
            break;
          case 'قيد الانتظار':
            hue = BitmapDescriptor.hueOrange;
            break;
          case 'ملغية':
          case 'ملغي':
            hue = BitmapDescriptor.hueRed;
            break;
          default:
            hue = BitmapDescriptor.hueBlue;
        }

        markers.add(
          Marker(
            markerId: MarkerId('report_${report.id}'),
            position: LatLng(report.lat, report.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            infoWindow: InfoWindow(
              title: 'بلاغ رقم ${report.id}',
              snippet: 'الحالة: ${report.status}',
            ),
          ),
        );
      }
    }

    // Add Container Markers
    if (mapVM.showContainers) {
      for (var container in data.containers) {
        if (container.lat == 0.0 || container.lng == 0.0) continue;

        markers.add(
          Marker(
            markerId: MarkerId('container_${container.id}'),
            position: LatLng(container.lat, container.lng),
            icon:
                mapVM.containerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
            infoWindow: InfoWindow(
              title: container.locationName,
              snippet: 'النوع: ${container.type}',
            ),
          ),
        );
      }
    }

    return markers;
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: const Color(0xFF2E7D32)),
        ),
      ),
    );
  }
}
