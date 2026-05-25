import '../../../../shared/models/item_model.dart';

abstract class ReportsRepository {
  Future<List<Item>> getItems();
  Future<void> addReport(Item item);
  Future<void> deleteReport(String id);
  Future<void> updateItemStatus(String id, String status);
}
