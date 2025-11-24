import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orm/src/utils/query_condition.dart';
import 'adapter.dart';

class FirebaseAdapter extends Adapter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseAdapter(super.collection);

  @override
  Future<Map<String, dynamic>?> findOrCreate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final docRef = _db.collection(collection).doc(id);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(data);
      final createdDoc = await docRef.get();
      final val = createdDoc.data();
      val?['id'] = createdDoc.id;
      return createdDoc.data();
    } else {
      return doc.data();
    }
  }

  @override
  Future<Map<String, dynamic>?> find(String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  @override
  Future<List<Map<String, dynamic>>> all() async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> where(
    String field,
    dynamic isEqualTo,
  ) async {
    final snap = await _db
        .collection(collection)
        .where(field, isEqualTo: isEqualTo)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  @override
  Future<String?> create(Map<String, dynamic> data, {String? id}) async {
    final docRef = id != null
        ? _db.collection(collection).doc(id)
        : _db.collection(collection).doc();

    await docRef.set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await _db.collection(collection).doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> appendToArray(String id, String field, dynamic value) async {
    await _db.collection(collection).doc(id).update({
      field: FieldValue.arrayUnion([value]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFromArray(String id, String field, dynamic value) async {
    await _db.collection(collection).doc(id).update({
      field: FieldValue.arrayRemove([value]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

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
    final query = await _db
        .collection(collection)
        .where(
          field,
          isEqualTo: isEqualTo,
          isNotEqualTo: isNotEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayContainsAny: arrayContainsAny,
          whereIn: whereIn,
          whereNotIn: whereNotIn,
          isNull: isNull,
        )
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return {'id': doc.id, ...doc.data()};
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAll() {
    return _db
        .collection(collection)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

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
  }) {
    return _db
        .collection(collection)
        .where(
          field,
          isEqualTo: isEqualTo,
          isNotEqualTo: isNotEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayContainsAny: arrayContainsAny,
          whereIn: whereIn,
          whereNotIn: whereNotIn,
          isNull: isNull,
        )
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  @override
  Stream<Map<String, dynamic>?> watch(String id) {
    return _db.collection(collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    });
  }

  Stream<List<T>> watchFieldListWhere<T>({
    required String field,
    required String whereField,
    required dynamic isEqual,
  }) {
    return FirebaseFirestore.instance
        .collection(collection)
        .where(whereField, isEqualTo: isEqual)
        .snapshots()
        .map((snapshot) {
          final values = snapshot.docs
              .map((doc) => doc.data()[field])
              .whereType<T>()
              .toList();

          return values;
        });
  }

  Stream<R> watchWhereConditions<R>(
    List<QueryCondition> conditions, {
    required R Function(List<QueryDocumentSnapshot<Object?>> docs) reducer,
  }) {
    Query query = _db.collection(collection);

    for (final condition in conditions) {
      query = query.where(
        condition.field,
        isEqualTo: condition.isEqualTo,
        isNotEqualTo: condition.isNotEqualTo,
        isLessThan: condition.isLessThan,
        isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
        isGreaterThan: condition.isGreaterThan,
        isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
        arrayContains: condition.arrayContains,
        arrayContainsAny: condition.arrayContainsAny,
        whereIn: condition.whereIn,
        whereNotIn: condition.whereNotIn,
        isNull: condition.isNull,
      );
    }
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      return reducer(docs);
    });
  }

  Stream<int> watchFieldSum({
    required String field,
    List<QueryCondition> conditions = const [],
  }) {
    Query query = _db.collection(collection);

    for (final condition in conditions) {
      query = query.where(
        condition.field,
        isEqualTo: condition.isEqualTo,
        isNotEqualTo: condition.isNotEqualTo,
        isLessThan: condition.isLessThan,
        isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
        isGreaterThan: condition.isGreaterThan,
        isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
        arrayContains: condition.arrayContains,
        arrayContainsAny: condition.arrayContainsAny,
        whereIn: condition.whereIn,
        whereNotIn: condition.whereNotIn,
        isNull: condition.isNull,
      );
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.fold<int>(0, (acc, doc) {
        final data = doc.data();
        if (data is! Map<String, dynamic>) return acc;

        final value = data[field];

        if (value is int) return acc + value;
        if (value is num) return acc + value.toInt();
        return acc;
      });
    });
  }
}
