import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/models/item_model.dart';
import '../../data/repositories/firebase_reports_repository.dart';

// Provides the repository instance
final reportsRepositoryProvider = Provider<FirebaseReportsRepository>((ref) {
  return FirebaseReportsRepository();
});

// Fetches the raw list of items from Firestore
final reportsListProvider = FutureProvider<List<Item>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  return repository.getItems();
});

// Search and Filter States
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All Items');
final searchRadiusProvider = StateProvider<double>((ref) => 15.0);
final searchCenterProvider = StateProvider<LatLng?>((ref) => const LatLng(40.785091, -73.968285)); // Central Park NYC default
final selectedLocationNameProvider = StateProvider<String>((ref) => 'New York City, NY');

// Derived provider that filters items reactively based on active search criteria
final filteredReportsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  final reportsAsync = ref.watch(reportsListProvider);
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final radius = ref.watch(searchRadiusProvider);
  final center = ref.watch(searchCenterProvider);

  return reportsAsync.whenData((reports) {
    return reports.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase());
      
      final matchesCategory = category == 'All Items' || item.category == category;
      
      bool matchesRadius = true;
      if (center != null && item.latitude != null && item.longitude != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          center.latitude,
          center.longitude,
          item.latitude!,
          item.longitude!,
        );
        final distanceInKm = distanceInMeters / 1000.0;
        matchesRadius = distanceInKm <= radius;
      }
      
      return matchesSearch && matchesCategory && matchesRadius;
    }).toList();
  });
});
