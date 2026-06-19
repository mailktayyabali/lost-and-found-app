import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../shared/models/item_model.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lost_and_found.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Upgrade database version to support multiple images
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS items_cache');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items_cache (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        isLost INTEGER NOT NULL,
        imageUrl TEXT NOT NULL,
        timeAgo TEXT NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        createdBy TEXT,
        reporterName TEXT,
        reporterEmail TEXT,
        reporterPhone TEXT,
        latitude REAL,
        longitude REAL,
        imageUrls TEXT
      )
    ''');
  }

  Future<void> cacheItems(List<Item> items) async {
    final db = await database;
    
    // Start a transaction to clear and reload the local SQLite cache
    await db.transaction((txn) async {
      await txn.delete('items_cache');
      
      for (final item in items) {
        await txn.insert(
          'items_cache',
          {
            'id': item.id,
            'title': item.title,
            'location': item.location,
            'description': item.description,
            'isLost': item.isLost ? 1 : 0,
            'imageUrl': item.imageUrl,
            'timeAgo': item.timeAgo,
            'category': item.category,
            'status': item.status,
            'createdBy': item.createdBy,
            'reporterName': item.reporterName,
            'reporterEmail': item.reporterEmail,
            'reporterPhone': item.reporterPhone,
            'latitude': item.latitude,
            'longitude': item.longitude,
            'imageUrls': jsonEncode(item.imageUrls), // Store list as JSON text
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Item>> getCachedItems() async {
    final db = await database;
    final result = await db.query('items_cache');

    return result.map((map) {
      final String? rawImageUrls = map['imageUrls'] as String?;
      final List<String> parsedImageUrls = rawImageUrls != null
          ? List<String>.from(jsonDecode(rawImageUrls))
          : [map['imageUrl'] as String? ?? ''];

      return Item(
        id: map['id'] as String,
        title: map['title'] as String,
        location: map['location'] as String,
        description: map['description'] as String,
        isLost: (map['isLost'] as int) == 1,
        imageUrl: map['imageUrl'] as String,
        timeAgo: map['timeAgo'] as String,
        category: map['category'] as String,
        status: map['status'] as String,
        createdBy: map['createdBy'] as String?,
        reporterName: map['reporterName'] as String?,
        reporterEmail: map['reporterEmail'] as String?,
        reporterPhone: map['reporterPhone'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        imageUrls: parsedImageUrls,
      );
    }).toList();
  }
}
