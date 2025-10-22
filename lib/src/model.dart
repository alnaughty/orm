import 'package:orm/src/adapters/adapter.dart';
import 'package:orm/src/utils/query_condition.dart';

abstract class Model {
  Adapter get adapter;
  final String id;
  const Model({required this.id});

  Map<String, dynamic> toMap();
  Model fromMap(Map<String, dynamic> map);

  Future<List<Model>> all() async {
    final data = await adapter.all();
    return data.map((e) => fromMap(e)).toList();
  }

  Future<List<Model>> where(List<QueryCondition> conditions) async {
    if (conditions.isEmpty) return [];
    final first = conditions.first;

    final results = await adapter.where(first.field, first.isEqualTo);
    return results.map((e) => fromMap(e)).toList();
  }

  Stream<List<Model>> watchAll() {
    return adapter.watchAll().map(
      (list) => list.map((e) => fromMap(e)).toList(),
    );
  }

  Stream<List<Model>> watchList({List<QueryCondition>? conditions}) {
    if (conditions == null || conditions.isEmpty) {
      return watchAll();
    }

    final first = conditions.first;

    return adapter
        .watchWhere(
          first.field,
          isEqualTo: first.isEqualTo,
          isNotEqualTo: first.isNotEqualTo,
          isLessThan: first.isLessThan,
          isLessThanOrEqualTo: first.isLessThanOrEqualTo,
          isGreaterThan: first.isGreaterThan,
          isGreaterThanOrEqualTo: first.isGreaterThanOrEqualTo,
          arrayContains: first.arrayContains,
          arrayContainsAny: first.arrayContainsAny,
          whereIn: first.whereIn,
          whereNotIn: first.whereNotIn,
          isNull: first.isNull,
        )
        .map((list) => list.map((e) => fromMap(e)).toList());
  }

  Future<String?> create() async {
    final data = toMap();
    final nid = await adapter.create(data);
    return nid;
  }

  Future<void> update() async {
    await adapter.update(id, toMap());
  }

  Future<void> delete() async {
    await adapter.delete(id);
  }

  Future<Model?> find(String id) async {
    final data = await adapter.find(id);
    return data != null ? fromMap(data) : null;
  }

  Stream<Model?> watch(String id) {
    return adapter.watch(id).map((e) {
      if (e == null) return null;
      return fromMap(e);
    });
  }
}
