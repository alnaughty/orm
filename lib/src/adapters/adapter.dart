abstract class Adapter {
  Future<Map<String, dynamic>?> find(String collection, String id);

  Future<List<Map<String, dynamic>>> all(String collection);

  Future<List<Map<String, dynamic>>> where(
    String collection,
    String field,
    dynamic isEqualTo,
  );

  Future<String?> create(String collection, Map<String, dynamic> data);

  Future<void> update(String collection, String id, Map<String, dynamic> data);

  Future<bool> delete(String collection, String id);

  Future<void> appendToArray(
    String collection,
    String id,
    String field,
    dynamic value,
  );

  Future<void> removeFromArray(
    String collection,
    String id,
    String field,
    dynamic value,
  );

  Future<Map<String, dynamic>?> findWhere(
    String collection,
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
  });

  Stream<List<Map<String, dynamic>>> watchAll(String collection) =>
      const Stream.empty();

  Stream<List<Map<String, dynamic>>> watchWhere(
    String collection,
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
  }) => const Stream.empty();

  Stream<Map<String, dynamic>?> watch(String collection, String id) =>
      const Stream.empty();

  static late Adapter defaultInstance;
}
