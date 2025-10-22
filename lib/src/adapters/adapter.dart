abstract class Adapter {
  final String collection;
  const Adapter(this.collection);
  Future<Map<String, dynamic>?> findOrCreate(
    String id,
    Map<String, dynamic> data,
  );
  Future<Map<String, dynamic>?> find(String id);

  Future<List<Map<String, dynamic>>> all();

  Future<List<Map<String, dynamic>>> where(String field, dynamic isEqualTo);

  Future<String?> create(Map<String, dynamic> data);

  Future<void> update(String id, Map<String, dynamic> data);

  Future<bool> delete(String id);

  Future<void> appendToArray(String id, String field, dynamic value);

  Future<void> removeFromArray(String id, String field, dynamic value);

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
  });

  Stream<List<Map<String, dynamic>>> watchAll() => const Stream.empty();

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
  }) => const Stream.empty();

  Stream<Map<String, dynamic>?> watch(String id) => const Stream.empty();

  static late Adapter defaultInstance;
}
