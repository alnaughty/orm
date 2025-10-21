import 'package:orm/src/adapters/adapter.dart';
import 'package:orm/src/utils/query_condition.dart';

abstract class Model {
  String get collection;
  String? id;

  Map<String, dynamic> toMap();
  Model fromMap(Map<String, dynamic> map);

  Future<List<Model>> all() async {
    final data = await Adapter.defaultInstance.all(collection);
    return data.map((e) => fromMap(e)).toList();
  }

  Future<List<Model>> where(List<QueryCondition> conditions) async {
    if (conditions.isEmpty) return [];
    final first = conditions.first;

    final results = await Adapter.defaultInstance.where(
      collection,
      first.field,
      first.isEqualTo,
    );
    return results.map((e) => fromMap(e)).toList();
  }

  Stream<List<Model>> watchAll() {
    return Adapter.defaultInstance
        .watchAll(collection)
        .map((list) => list.map((e) => fromMap(e)).toList());
  }

  Stream<List<Model>> watchList({List<QueryCondition>? conditions}) {
    if (conditions == null || conditions.isEmpty) {
      return watchAll();
    }

    final first = conditions.first;

    return Adapter.defaultInstance
        .watchWhere(
          collection,
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
    final id = await Adapter.defaultInstance.create(collection, data);
    this.id = id;
    return id;
  }

  Future<void> update() async {
    if (id == null) throw Exception('Cannot update without ID');
    await Adapter.defaultInstance.update(collection, id!, toMap());
  }

  Future<void> delete() async {
    if (id == null) throw Exception('Cannot delete without ID');
    await Adapter.defaultInstance.delete(collection, id!);
  }

  Future<Model?> find(String id) async {
    final data = await Adapter.defaultInstance.find(collection, id);
    return data != null ? fromMap(data) : null;
  }

  Stream<Model?> watch(String id) {
    return Adapter.defaultInstance.watch(collection, id).map((e) {
      if (e == null) return null;
      return fromMap(e);
    });
  }
}
