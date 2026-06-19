import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String location;
  final String description;
  final bool isLost;
  final String imageUrl;
  final String timeAgo;
  final String category;
  final String status; // 'LOST', 'FOUND', 'RESOLVED', 'ACTIVE'
  final String? createdBy;
  final String? reporterName;
  final String? reporterEmail;
  final String? reporterPhone;
  final double? latitude;
  final double? longitude;

  final List<String> imageUrls;

  const Item({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.isLost,
    required this.imageUrl,
    required this.timeAgo,
    this.category = 'Other',
    this.status = 'ACTIVE',
    this.createdBy,
    this.reporterName,
    this.reporterEmail,
    this.reporterPhone,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
  });

  static String _calculateTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'some time ago';
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      final parsed = DateTime.tryParse(timestamp);
      if (parsed == null) return 'some time ago';
      dateTime = parsed;
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return 'some time ago';
    }
    
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  factory Item.fromJson(Map<String, dynamic> json, String docId) {
    final rawImageUrls = json['imageUrls'];
    final List<String> parsedImageUrls = rawImageUrls != null
        ? List<String>.from(rawImageUrls)
        : [json['imageUrl'] as String? ?? ''];

    final calculatedTime = _calculateTimeAgo(json['createdAt'] ?? json['dateReported']);
    final displayTime = calculatedTime == 'some time ago' ? (json['timeAgo'] ?? 'Just now') : calculatedTime;

    return Item(
      id: docId,
      title: json['title'] ?? json['itemName'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      isLost: json['isLost'] ?? true,
      imageUrl: parsedImageUrls.isNotEmpty ? parsedImageUrls.first : (json['imageUrl'] ?? ''),
      timeAgo: displayTime,
      category: json['category'] ?? 'Other',
      status: json['status'] ?? ((json['isLost'] ?? true) ? 'LOST' : 'FOUND'),
      createdBy: json['createdBy'],
      reporterName: json['reporterName'],
      reporterEmail: json['reporterEmail'],
      reporterPhone: json['reporterPhone'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      imageUrls: parsedImageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'itemName': title,
      'location': location,
      'description': description,
      'isLost': isLost,
      'imageUrl': imageUrl,
      'timeAgo': timeAgo,
      'category': category,
      'status': status,
      'createdBy': createdBy,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
      'reporterPhone': reporterPhone,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
    };
  }

  Item copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    bool? isLost,
    String? imageUrl,
    String? timeAgo,
    String? category,
    String? status,
    String? createdBy,
    String? reporterName,
    String? reporterEmail,
    String? reporterPhone,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      isLost: isLost ?? this.isLost,
      imageUrl: imageUrl ?? this.imageUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      category: category ?? this.category,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      reporterName: reporterName ?? this.reporterName,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  String get displayLocation {
    // If it's a raw coordinate format, clean it up for card/list display
    final match = RegExp(
      r'(?:Latitude|Lat):\s*([-\d.]+),\s*(?:Longitude|Lon|Lng):\s*([-\d.]+)',
      caseSensitive: false,
    ).firstMatch(location);

    if (match != null) {
      final lat = double.tryParse(match.group(1) ?? '');
      final lng = double.tryParse(match.group(2) ?? '');
      if (lat != null && lng != null) {
        return _formatCoords(lat, lng);
      }
    }

    final matchRaw = RegExp(r'^\s*([-\d.]+)\s*,\s*([-\d.]+)\s*$').firstMatch(location);
    if (matchRaw != null) {
      final lat = double.tryParse(matchRaw.group(1) ?? '');
      final lng = double.tryParse(matchRaw.group(2) ?? '');
      if (lat != null && lng != null) {
        return _formatCoords(lat, lng);
      }
    }

    return location;
  }

  static String _formatCoords(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
