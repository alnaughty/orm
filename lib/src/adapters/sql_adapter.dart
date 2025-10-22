import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:orm/src/adapters/adapter.dart';

class SqlAdapter extends Adapter {
  static Database? _db;
  static bool _initialized = false;

  SqlAdapter(super.collection);

  static Future<void> initialize({String? dbName}) async {
    if (_initialized) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName ?? 'app_database.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {},
    );

    _initialized = true;
  }

  Future<void> _ensureTable() async {
    await _db!.execute('''
      CREATE TABLE IF NOT EXISTS $collection (
        id TEXT PRIMARY KEY,
        data TEXT
      )
    ''');
  }

  @override
  Future<Map<String, dynamic>?> findOrCreate(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _ensureTable();
    final existing = await find(id);
    if (existing != null) return existing;
    await create({...data, 'id': id});
    return find(id);
  }

  @override
  Future<Map<String, dynamic>?> find(String id) async {
    await _ensureTable();
    final result = await _db!.query(
      collection,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    final row = result.first;
    return {'id': row['id'], ...jsonDecode(row['data'] as String)};
  }

  @override
  Future<List<Map<String, dynamic>>> all() async {
    await _ensureTable();
    final result = await _db!.query(collection);
    return result;
  }

  /// 🟢 WHERE (basic equality only)
  @override
  Future<List<Map<String, dynamic>>> where(
    String field,
    dynamic isEqualTo,
  ) async {
    final allData = await all();
    return allData.where((e) => e[field] == isEqualTo).toList();
  }

  /// 🟢 CREATE
  @override
  Future<String?> create(Map<String, dynamic> data) async {
    await _ensureTable();
    final id = data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _db!.insert(collection, {
      'id': id,
      'data': jsonEncode(data),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  /// 🟢 UPDATE
  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _ensureTable();
    await _db!.update(
      collection,
      {'data': jsonEncode(data)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 🟢 DELETE
  @override
  Future<bool> delete(String id) async {
    await _ensureTable();
    final count = await _db!.delete(
      collection,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  /// 🟢 APPEND TO ARRAY FIELD
  @override
  Future<void> appendToArray(String id, String field, dynamic value) async {
    final existing = await find(id);
    if (existing == null) return;
    final list = List.from(existing[field] ?? []);
    list.add(value);
    existing[field] = list;
    await update(id, existing);
  }

  /// 🟢 REMOVE FROM ARRAY FIELD
  @override
  Future<void> removeFromArray(String id, String field, dynamic value) async {
    final existing = await find(id);
    if (existing == null) return;
    final list = List.from(existing[field] ?? []);
    list.remove(value);
    existing[field] = list;
    await update(id, existing);
  }

  /// 🟢 FIND WHERE (basic filters)
  @override
  Future<Map<String, dynamic>?> findWhere(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) async {
    final allData = await all();
    return allData.firstWhere((e) {
      if (isEqualTo != null && e[field] != isEqualTo) return false;
      if (isNotEqualTo != null && e[field] == isNotEqualTo) return false;
      if (isLessThan != null && !(e[field] < isLessThan)) return false;
      if (isGreaterThan != null && !(e[field] > isGreaterThan)) return false;
      if (isNull != null && (isNull ? e[field] != null : e[field] == null)) {
        return false;
      }
      return true;
    }, orElse: () => {});
  }

  /// 🟢 WATCH (basic — emits single snapshot)
  @override
  Stream<Map<String, dynamic>?> watch(String id) async* {
    yield await find(id);
  }

  /// 🟢 WATCH ALL (polling style)
  @override
  Stream<List<Map<String, dynamic>>> watchAll() async* {
    yield await all();
  }

  /// 🟢 WATCH WHERE (polling style)
  @override
  Stream<List<Map<String, dynamic>>> watchWhere(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) async* {
    final results = await where(field, isEqualTo);
    yield results;
  }
}
