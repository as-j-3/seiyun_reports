import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/viewmodel/citizen_reports_viewmodel.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/viewmodel/pickup_schedules_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/viewmodel/map_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/view/widgets/map_filter_chip.dart';
import 'package:seiyun_reports_app/screens/map/view/widgets/map_info_bottom_sheet.dart';

class MapScreen extends StatelessWidget {
  final LatLng? initialLocation;
  final String? initialTitle;

  const MapScreen({super.key, this.initialLocation, this.initialTitle});

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();
    final reportsProvider = context.watch<CitizenReportsViewModel>();
    final pickupProvider = context.watch<PickupSchedulesViewModel>();

    final Set<Marker> markers = _buildMarkers(context, mapVM, reportsProvider, pickupProvider);
    
    // Add temporary marker for initial location if provided
    if (initialLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('initial_focus'),
          position: initialLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: initialTitle ?? 'موقع البلاغ'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة سيئون'),
        actions: [
          IconButton(
            icon: Icon(mapVM.isSatellite ? Icons.map_outlined : Icons.satellite_alt_outlined),
            tooltip: mapVM.isSatellite ? 'العرض العادي' : 'عرض القمر الصناعي',
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
              if (initialLocation != null) {
                // Focus on the location after a short delay to ensure map is ready
                Future.delayed(const Duration(milliseconds: 500), () {
                  mapVM.focusOnLocation(initialLocation!);
                });
              }
            },
            initialCameraPosition: CameraPosition(
              target: initialLocation ?? MapViewModel.seiyunCenter,
              zoom: initialLocation != null ? 17.0 : 14.0,
            ),
            mapType: mapVM.isSatellite ? MapType.satellite : MapType.normal,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
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
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(
    BuildContext context,
    MapViewModel mapVM,
    CitizenReportsViewModel reportsProvider,
    PickupSchedulesViewModel pickupProvider,
  ) {
    final Set<Marker> markers = {};

    // Add Report Markers
    if (mapVM.showReports) {
      for (var report in reportsProvider.reports) {
        markers.add(
          Marker(
            markerId: MarkerId('report_${report.id}'),
            position: LatLng(report.latitude, report.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () => MapInfoBottomSheet.show(
              context,
              report.title,
              'الحالة: ${report.status}\nبواسطة: ${report.user_name}',
              report.report_image,
            ),
          ),
        );
      }
    }


    // Add Container Markers
    if (mapVM.showContainers) {
      for (var container in pickupProvider.nearbyContainers) {
        markers.add(
          Marker(
            markerId: MarkerId('container_${container.id}'),
            position: LatLng(container.latitude, container.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () => MapInfoBottomSheet.show(
              context,
              container.name,
              'العنوان: ${container.address}\nالمسافة: ${container.distance.toStringAsFixed(0)} متر\nالحالة: ${container.status == "full"
                  ? "ممتلئة"
                  : container.status == "half"
                  ? "متوسطة"
                  : "فارغة"}',
              null,
            ),
          ),
        );
      }
    }

    return markers;
  }
}
