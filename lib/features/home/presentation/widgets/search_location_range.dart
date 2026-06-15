import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/mock_map_widget.dart';

class SearchLocationRange extends StatelessWidget {
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;
  final String locationName;
  final VoidCallback onMapTap;
  final LatLng? center;
  final void Function(LatLng point, String address)? onLocationChanged;

  const SearchLocationRange({
    super.key,
    required this.sliderValue,
    required this.onSliderChanged,
    required this.locationName,
    required this.onMapTap,
    this.center,
    this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOCATION RANGE',
                style: TextStyle(
                  color: context.colors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${sliderValue.toInt()} km',
                  style: TextStyle(
                    color: context.colors.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: context.colors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.fieldBorder),
            ),
            child: Column(
              children: [
                MockMapWidget(
                  height: 120,
                  locationName: locationName,
                  isPicker: true,
                  center: center,
                  radiusKm: sliderValue,
                  onLocationChanged: onLocationChanged,
                  onTap: onMapTap,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: context.colors.textLight, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationName,
                        style: TextStyle(
                          color: context.colors.textDark,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: context.colors.primaryTeal,
                    inactiveTrackColor: context.colors.fieldBorder,
                    thumbColor: context.colors.primaryTeal,
                    overlayColor: context.colors.primaryTeal.withValues(alpha: 0.2),
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 1,
                    max: 50,
                    onChanged: onSliderChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
