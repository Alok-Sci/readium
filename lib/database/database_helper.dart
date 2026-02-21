import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:readium/features/history/models/article_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const String _customPathKey = 'custom_database_path';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> getDatabasePath() async {
    final prefs = await SharedPreferences.getInstance();
    final customPath = prefs.getString(_customPathKey);

    if (customPath != null && customPath.isNotEmpty) {
      return join(customPath, 'readium.db');
    }

    return join(await getDatabasesPath(), 'readium.db');
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasePath();
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> changeDatabasePath(String newPath) async {
    // Close existing database
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Get old database path
    final oldPath = await getDatabasePath();

    // Save new path to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customPathKey, newPath);

    // Get new database path
    final newDbPath = join(newPath, 'readium.db');

    // Copy database file if it exists
    final oldFile = File(oldPath);
    if (await oldFile.exists()) {
      await oldFile.copy(newDbPath);
    }

    // Reinitialize database
    _database = await _initDatabase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE article_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        originalUrl TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        coverImageUrl TEXT,
        authorName TEXT NOT NULL,
        authorImageUrl TEXT NOT NULL,
        readTime TEXT NOT NULL,
        publishDate TEXT NOT NULL,
        isMemberOnly INTEGER NOT NULL,
        readAt INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertArticleHistory(ArticleHistory article) async {
    final db = await database;

    // Check if article already exists
    final existing = await db.query(
      'article_history',
      where: 'originalUrl = ?',
      whereArgs: [article.originalUrl],
    );

    if (existing.isNotEmpty) {
      // Update the readAt timestamp if article already exists
      return await db.update(
        'article_history',
        {'readAt': article.readAt.millisecondsSinceEpoch},
        where: 'originalUrl = ?',
        whereArgs: [article.originalUrl],
      );
    } else {
      // Insert new article
      return await db.insert('article_history', article.toMap());
    }
  }

  Future<List<ArticleHistory>> getArticleHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'article_history',
      orderBy: 'readAt DESC',
    );

    return List.generate(maps.length, (i) {
      return ArticleHistory.fromMap(maps[i]);
    });
  }

  Future<int> deleteArticleHistory(int id) async {
    final db = await database;
    return await db.delete('article_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllHistory() async {
    final db = await database;
    return await db.delete('article_history');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
