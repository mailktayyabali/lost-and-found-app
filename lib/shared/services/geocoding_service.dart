import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude',
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'LostAndFoundApp/1.0.0 (contact: support@lostandfoundapp.example.com; pkg: com.example.lost_and_found)',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          // Clean up the name a bit (e.g. shorten if it's very long)
          final parts = displayName.split(', ');
          if (parts.length > 4) {
            return parts.sublist(0, 4).join(', ');
          }
          return displayName;
        }
      } else {
        debugPrint('GeocodingService API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('GeocodingService Exception: $e');
    }
    return null;
  }
}
