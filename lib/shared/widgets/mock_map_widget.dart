import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../services/geocoding_service.dart';

class MockMapWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isPicker;
  final String locationName;
  final double height;
  
  // Custom interactive params
  final LatLng? center;
  final double? radiusKm;
  final List<LatLng>? markerPoints;
  final List<Marker>? customMarkers;
  final Function(LatLng coordinate, String address)? onLocationChanged;
  final bool showUserLocationButton;

  const MockMapWidget({
    super.key,
    this.onTap,
    this.isPicker = false,
    this.locationName = 'Central Park, NYC',
    this.height = 200,
    this.center,
    this.radiusKm,
    this.markerPoints,
    this.customMarkers,
    this.onLocationChanged,
    this.showUserLocationButton = true,
  });

  @override
  State<MockMapWidget> createState() => _MockMapWidgetState();
}

class _MockMapWidgetState extends State<MockMapWidget> {
  late final MapController _mapController;
  LatLng? _pickedLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.center != null) {
      _pickedLocation = widget.center;
    } else if (widget.isPicker) {
      // For picker, start empty or at default
      _pickedLocation = const LatLng(40.785091, -73.968285);
    } else {
      _pickedLocation = const LatLng(40.785091, -73.968285);
    }
  }

  @override
  void didUpdateWidget(covariant MockMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.center != null && widget.center != oldWidget.center) {
      setState(() {
        _pickedLocation = widget.center;
      });
      _mapController.move(widget.center!, _mapController.camera.zoom);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        return;
      } 

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      
      _mapController.move(latLng, 15.0);
      
      if (widget.isPicker) {
        setState(() {
          _pickedLocation = latLng;
        });
        
        final address = await GeocodingService.reverseGeocode(latLng.latitude, latLng.longitude);
        if (widget.onLocationChanged != null) {
          widget.onLocationChanged!(latLng, address ?? 'Latitude: ${latLng.latitude.toStringAsFixed(4)}, Longitude: ${latLng.longitude.toStringAsFixed(4)}');
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultCenter = widget.center ?? _pickedLocation ?? const LatLng(40.785091, -73.968285);
    
    // Construct Markers
    final List<Marker> mapMarkers = [];
    
    // If it's a picker and we have a picked location, show it
    if (widget.isPicker && _pickedLocation != null) {
      mapMarkers.add(
        Marker(
          point: _pickedLocation!,
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            color: Colors.redAccent,
            size: 40,
          ),
        ),
      );
    }
    
    // Add additional markers if provided
    if (widget.markerPoints != null) {
      for (final pt in widget.markerPoints!) {
        mapMarkers.add(
          Marker(
            point: pt,
            width: 80,
            height: 80,
            child: const Icon(
              Icons.location_on,
              color: Colors.teal,
              size: 35,
            ),
          ),
        );
      }
    }

    if (widget.customMarkers != null) {
      mapMarkers.addAll(widget.customMarkers!);
    }

    // Radius Circle
    final List<CircleMarker> circles = [];
    if (widget.radiusKm != null) {
      circles.add(
        CircleMarker(
          point: defaultCenter,
          radius: widget.radiusKm! * 1000, // convert km to meters
          useRadiusInMeter: true,
          color: context.colors.primaryTeal.withValues(alpha: 0.15),
          borderColor: context.colors.primaryTeal,
          borderStrokeWidth: 2,
        ),
      );
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E3DF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: defaultCenter,
              initialZoom: widget.radiusKm != null ? _zoomForRadius(widget.radiusKm!) : 13.0,
              onTap: (tapPosition, point) async {
                if (widget.onTap != null) {
                  widget.onTap!;
                }
                if (widget.isPicker) {
                  setState(() {
                    _pickedLocation = point;
                  });
                  final address = await GeocodingService.reverseGeocode(point.latitude, point.longitude);
                  if (widget.onLocationChanged != null) {
                    widget.onLocationChanged!(point, address ?? 'Latitude: ${point.latitude.toStringAsFixed(4)}, Longitude: ${point.longitude.toStringAsFixed(4)}');
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lost_and_found',
              ),
              if (circles.isNotEmpty)
                CircleLayer(circles: circles),
              if (mapMarkers.isNotEmpty)
                MarkerLayer(markers: mapMarkers),
            ],
          ),
          
          // User location button
          if (widget.showUserLocationButton)
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: _isLoadingLocation ? null : _moveToCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ]
                  ),
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.my_location, color: context.colors.primaryTeal),
                ),
              ),
            ),

          // Label display
          if (!widget.isPicker && widget.locationName.isNotEmpty && widget.locationName != 'Nearby Items')
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]
                ),
                child: Text(
                  widget.locationName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _zoomForRadius(double radiusKm) {
    if (radiusKm <= 1) return 14.5;
    if (radiusKm <= 2) return 13.5;
    if (radiusKm <= 5) return 12.0;
    if (radiusKm <= 10) return 11.0;
    if (radiusKm <= 20) return 10.0;
    return 9.0;
  }
}
