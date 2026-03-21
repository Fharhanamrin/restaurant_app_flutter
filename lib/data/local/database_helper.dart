import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/restaurant.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  static const String _tableFavorites = 'favorites';

  Future<Database> get database async => _database ??= await _initDb();

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'restaurant_app.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableFavorites (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        pictureId TEXT NOT NULL,
        city TEXT NOT NULL,
        rating REAL NOT NULL
      )
    ''');
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      _tableFavorites,
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(_tableFavorites, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final maps = await db.query(_tableFavorites);
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final result = await db.query(
      _tableFavorites,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }
}
