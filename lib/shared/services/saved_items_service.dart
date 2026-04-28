import 'package:flutter/material.dart';
import '../models/item_model.dart';

class SavedItemsService extends ChangeNotifier {
  static final SavedItemsService _instance = SavedItemsService._internal();
  factory SavedItemsService() => _instance;
  SavedItemsService._internal();

  final List<Item> _savedItems = [];

  List<Item> get savedItems => List.unmodifiable(_savedItems);

  bool isSaved(String id) {
    return _savedItems.any((item) => item.id == id);
  }

  void toggleSave(Item item) {
    if (isSaved(item.id)) {
      _savedItems.removeWhere((i) => i.id == item.id);
    } else {
      _savedItems.add(item);
    }
    notifyListeners();
  }

  void removeAll() {
    _savedItems.clear();
    notifyListeners();
  }
}
