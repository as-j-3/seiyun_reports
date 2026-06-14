import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/map/viewmodel/map_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/view/widgets/map_filter_chip.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final mapVM = context.read<MapViewModel>();
      mapVM.fetchMapData();
      if (widget.initialLocation != null &&
          widget.initialLocation!.latitude != 0 &&
          !widget.isPicker) {
        mapVM.startLocationTracking(widget.initialLocation);
      } else if (widget.isPicker) {
        mapVM.startLocationTracking(null);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MapViewModel>().stopLocationTracking();
      }
    });
    super.dispose();
  }

  Future<void> _openExternalMap(LatLng location) async {
    final String url =
        'google.navigation:q=${location.latitude},${location.longitude}&mode=d';
    final Uri uri = Uri.parse(url);

    final String fallbackUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}&travelmode=driving';
    final Uri fallbackUri = Uri.parse(fallbackUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'عذراً، لم نتمكن من العثور على تطبيق خرائط للتوجيه',
              ),
            ),
          );
        }
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();
    final Set<Marker> markers = _buildMarkers(context, mapVM);
    final Set<Polyline> polylines = {};

    if (mapVM.isIsolatedMode &&
        mapVM.currentPosition != null &&
        mapVM.targetLocation != null) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_target'),
          points: [
            LatLng(
              mapVM.currentPosition!.latitude,
              mapVM.currentPosition!.longitude,
            ),
            mapVM.targetLocation!,
          ],
          color: AppTheme.primaryColor,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap,
        ),
      );
    }

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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isPicker ? 'تحديد الموقع على الخريطة' : 'خريطة سيئون',
          ),
          actions:
              widget.isPicker
                  ? [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed:
                            () => Navigator.pop(context, _pickedLocation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('حفظ'),
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
                      tooltip: 'نوع الخريطة',
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
                if (widget.initialLocation != null &&
                    widget.initialLocation!.latitude != 0 &&
                    !widget.isPicker) {
                  mapVM.focusOnLocation(widget.initialLocation!);
                }
              },
              initialCameraPosition: CameraPosition(
                target:
                    (widget.initialLocation == null ||
                            widget.initialLocation!.latitude == 0)
                        ? MapViewModel.seiyunCenter
                        : widget.initialLocation!,
                zoom:
                    (widget.initialLocation == null ||
                            widget.initialLocation!.latitude == 0)
                        ? 14.0
                        : 17.0,
              ),
              mapType: mapVM.isSatellite ? MapType.satellite : MapType.normal,
              markers: markers,
              polylines: polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onTap:
                  widget.isPicker
                      ? (loc) => setState(() => _pickedLocation = loc)
                      : null,
            ),

            if (mapVM.isIsolatedMode && mapVM.distanceToTarget != null)
              Positioned(
                bottom: 120, 
                left: 16,
                right: 16,
                child: _DistanceIndicator(
                  distance: mapVM.distanceToTarget!,
                  title: widget.initialTitle ?? "الحاوية المقصودة",
                  onNavigate: () => _openExternalMap(widget.initialLocation!),
                ),
              ),

            if (!widget.isPicker)
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
                        color: AppTheme.primaryColor,
                        icon: Icons.delete_outline,
                        isSelected: mapVM.showContainers,
                        onTap: () => mapVM.toggleContainers(),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              right: 12,
              bottom: mapVM.isIsolatedMode ? 100 : 40,
              child: Column(
                children: [
                  if (mapVM.isIsolatedMode) ...[
                    FloatingActionButton.small(
                      heroTag: 'clear_track',
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      onPressed: () => mapVM.stopLocationTracking(),
                      child: const Icon(Icons.clear),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () => mapVM.zoomIn(),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () => mapVM.zoomOut(),
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers(BuildContext context, MapViewModel mapVM) {
    final Set<Marker> markers = {};
    if (widget.isPicker) return markers;
    final data = mapVM.mapData;

    if (mapVM.isIsolatedMode && widget.initialLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('target_focus'),
          position: widget.initialLocation!,
          icon:
              mapVM.containerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: widget.initialTitle ?? 'الوجهة'),
        ),
      );
      return markers;
    }

    if (data == null) return markers;

    if (mapVM.showReports) {
      for (var report in data.reports) {
        if (report.lat == 0 || report.lng == 0) continue;
        markers.add(
          Marker(
            markerId: MarkerId('rep_${report.id}'),
            position: LatLng(report.lat, report.lng),
            icon: _getReportIcon(report.status, mapVM),
            infoWindow: InfoWindow(
              title: 'بلاغ ${report.id}',
              snippet: report.status,
            ),
          ),
        );
      }
    }

    if (mapVM.showContainers) {
      for (var container in data.containers) {
        if (container.lat == 0 || container.lng == 0) continue;
        final containerLatLng = LatLng(container.lat, container.lng);

        markers.add(
          Marker(
            markerId: MarkerId('cont_${container.id}'),
            position: containerLatLng,
            icon:
                mapVM.containerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
            infoWindow: InfoWindow(title: container.locationName),
            onTap: () {
              mapVM.startLocationTracking(containerLatLng);
              mapVM.focusOnLocation(containerLatLng);
            },
          ),
        );
      }
    }

    return markers;
  }

  BitmapDescriptor _getReportIcon(String status, MapViewModel mapVM) {
    switch (status) {
      case 'تم الحل':
        return mapVM.reportIconSolved ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'قيد المعالجة':
        return mapVM.reportIconProcessing ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'ملغية':
        return mapVM.reportIconCancelled ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return mapVM.reportIconPending ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }
}

class _DistanceIndicator extends StatelessWidget {
  final double distance;
  final String title;
  final VoidCallback onNavigate;

  const _DistanceIndicator({
    required this.distance,
    required this.title,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final String distText =
        distance > 1000
            ? "${(distance / 1000).toStringAsFixed(1)} كم"
            : "${distance.toStringAsFixed(0)} متر";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_walk,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "تبعد عنك $distText",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.navigation_outlined, size: 18),
            label: const Text("توجيه"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
