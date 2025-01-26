import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/quote_model.dart';

class DatabaseService extends ChangeNotifier {
  static Database? _db;
  // Web平台使用内存存储
  static final List<Quote> _memoryStore = [];
  
  Database get database {
    if (kIsWeb) {
      throw Exception('Web平台不支持数据库操作');
    }
    if (_db == null) {
      throw Exception('数据库未初始化');
    }
    return _db!;
  }

  static Future<void> init() async {
    // Web平台不初始化数据库
    if (kIsWeb) return;
    if (_db != null) return;

    try {
      if (Platform.isWindows) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final path = await getDatabasesPath();
      _db = await openDatabase(
        join(path, 'mind_trace.db'),
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE quotes(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, content TEXT, aiAnalysis TEXT)',
          );
        },
        version: 1,
      );
    } catch (e) {
      debugPrint('数据库初始化错误: $e');
      rethrow;
    }
  }

  Future<void> saveUserQuote(String content, [String? aiAnalysis]) async {
    try {
      final quote = Quote(
        date: DateTime.now().toIso8601String(),
        content: content,
        aiAnalysis: aiAnalysis,
      );
      
      if (kIsWeb) {
        // Web平台使用内存存储
        _memoryStore.insert(0, quote);
      } else {
        await database.insert('quotes', quote.toMap());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('保存引用错误: $e');
      rethrow;
    }
  }

  Future<List<Quote>> getAllQuotes() async {
    try {
      if (kIsWeb) {
        // Web平台返回内存中的数据
        return _memoryStore;
      }
      final List<Map<String, dynamic>> maps = await database.query('quotes', orderBy: 'date DESC');
      return maps.map((map) => Quote.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取引用错误: $e');
      return [];
    }
  }
}