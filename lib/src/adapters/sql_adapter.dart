import 'package:sqflite/sqflite.dart';
import 'adapter.dart';

class SqlAdapter extends Adapter {
  final Database db;
  SqlAdapter(this.db);

  @override
  Future<Map<String, dynamic>?> find(String table, String id) async {
    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Future<List<Map<String, dynamic>>> all(String table) async {
    return await db.query(table);
  }

  @override
  Future<List<Map<String, dynamic>>> where(
    String table,
    String field,
    dynamic isEqualTo,
  ) async {
    return await db.query(table, where: '$field = ?', whereArgs: [isEqualTo]);
  }

  @override
  Future<String?> create(String table, Map<String, dynamic> data) async {
    final id = await db.insert(table, data);
    return id.toString();
  }

  @override
  Future<void> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<bool> delete(String table, String id) async {
    final count = await db.delete(table, where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  @override
  Future<void> appendToArray(
    String table,
    String id,
    String field,
    dynamic value,
  ) async {
    // Emulate Firestore array append by manually loading & updating
    final row = await find(table, id);
    if (row == null) return;
    final current = (row[field] as List?) ?? [];
    current.add(value);
    await update(table, id, {field: current});
  }

  @override
  Future<void> removeFromArray(
    String table,
    String id,
    String field,
    dynamic value,
  ) async {
    final row = await find(table, id);
    if (row == null) return;
    final current = (row[field] as List?) ?? [];
    current.remove(value);
    await update(table, id, {field: current});
  }

  @override
  Future<Map<String, dynamic>?> findWhere(
    String table,
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
    final condition = isEqualTo != null ? '$field = ?' : '1=1';
    final args = isEqualTo != null ? [isEqualTo] : [];
    final result = await db.query(
      table,
      where: condition,
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}
