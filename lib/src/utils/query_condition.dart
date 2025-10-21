class QueryCondition {
  final String field;

  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final Iterable<Object?>? arrayContainsAny;
  final Iterable<Object?>? whereIn;
  final Iterable<Object?>? whereNotIn;
  final bool? isNull;

  const QueryCondition(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });

  String toSqlWhereClause() {
    if (isEqualTo != null) return '$field = ?';
    if (isNotEqualTo != null) return '$field != ?';
    if (isLessThan != null) return '$field < ?';
    if (isLessThanOrEqualTo != null) return '$field <= ?';
    if (isGreaterThan != null) return '$field > ?';
    if (isGreaterThanOrEqualTo != null) return '$field >= ?';
    if (isNull != null && isNull == true) return '$field IS NULL';
    if (isNull != null && isNull == false) return '$field IS NOT NULL';
    return '';
  }

  Object? get value {
    return isEqualTo ??
        isNotEqualTo ??
        isLessThan ??
        isLessThanOrEqualTo ??
        isGreaterThan ??
        isGreaterThanOrEqualTo ??
        arrayContains ??
        null;
  }

  /// Check if this condition matches a given data row (for in-memory filtering)
  bool matches(Map<String, dynamic> data) {
    final val = data[field];
    if (isEqualTo != null) return val == isEqualTo;
    if (isNotEqualTo != null) return val != isNotEqualTo;
    if (isLessThan != null && val is Comparable) {
      return val.compareTo(isLessThan) < 0;
    }
    if (isLessThanOrEqualTo != null && val is Comparable) {
      return val.compareTo(isLessThanOrEqualTo) <= 0;
    }
    if (isGreaterThan != null && val is Comparable) {
      return val.compareTo(isGreaterThan) > 0;
    }
    if (isGreaterThanOrEqualTo != null && val is Comparable) {
      return val.compareTo(isGreaterThanOrEqualTo) >= 0;
    }
    if (arrayContains != null && val is Iterable) {
      return val.contains(arrayContains);
    }
    if (arrayContainsAny != null && val is Iterable) {
      return val.any((v) => arrayContainsAny!.contains(v));
    }
    if (whereIn != null) return whereIn!.contains(val);
    if (whereNotIn != null) return !whereNotIn!.contains(val);
    if (isNull == true) return val == null;
    if (isNull == false) return val != null;
    return true;
  }

  @override
  String toString() =>
      'QueryCondition(field: $field, isEqualTo: $isEqualTo, isNotEqualTo: $isNotEqualTo, '
      'isLessThan: $isLessThan, isGreaterThan: $isGreaterThan)';
}
