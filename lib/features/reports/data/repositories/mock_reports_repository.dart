import '../../../../core/constants/mock_data.dart';
import '../../../../shared/models/item_model.dart';
import '../../domain/repositories/reports_repository.dart';

class MockReportsRepository implements ReportsRepository {
  // Singleton pattern for easy application-wide usage
  static final MockReportsRepository _instance = MockReportsRepository._internal();
  factory MockReportsRepository() => _instance;
  MockReportsRepository._internal();

  @override
  Future<List<Item>> getItems() async {
    // Return a copy to avoid accidental direct mutation outside the repository
    return List.from(MockData.items);
  }

  @override
  Future<void> addReport(Item item) async {
    MockData.items.insert(0, item);
  }

  @override
  Future<void> deleteReport(String id) async {
    MockData.items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> updateItemStatus(String id, String status) async {
    final index = MockData.items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updated = MockData.items[index].copyWith(
        status: status,
        isLost: status == 'LOST',
      );
      MockData.items[index] = updated;
    }
  }
}
