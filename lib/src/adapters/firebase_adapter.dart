import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<String?> create(Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
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
}
