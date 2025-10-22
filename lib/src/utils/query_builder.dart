import 'package:orm/src/adapters/adapter.dart';

class QueryBuilder {
  final Adapter adapter;
  final String collection;

  final Map<String, dynamic> _conditions = {};
  String? _orderField;
  bool _descending = false;
  int? _limit;

  QueryBuilder(this.adapter, this.collection);

  QueryBuilder where(String field, String operator, dynamic value) {
    _conditions[field] = {'op': operator, 'value': value};
    return this;
  }

  QueryBuilder orderBy(String field, {bool descending = false}) {
    _orderField = field;
    _descending = descending;
    return this;
  }

  QueryBuilder limit(int count) {
    _limit = count;
    return this;
  }

  Future<List<Map<String, dynamic>>> get() async {
    List<Map<String, dynamic>> results = await adapter.all();

    _conditions.forEach((field, cond) {
      final op = cond['op'];
      final val = cond['value'];

      results = results.where((row) {
        final dynamic fieldValue = row[field];
        switch (op) {
          case '=':
            return fieldValue == val;
          case '!=':
            return fieldValue != val;
          case '>':
            return fieldValue is num && fieldValue > val;
          case '<':
            return fieldValue is num && fieldValue < val;
          case '>=':
            return fieldValue is num && fieldValue >= val;
          case '<=':
            return fieldValue is num && fieldValue <= val;
          case 'contains':
            return fieldValue is List && fieldValue.contains(val);
          default:
            return false;
        }
      }).toList();
    });

    if (_orderField != null) {
      results.sort((a, b) {
        final aVal = a[_orderField];
        final bVal = b[_orderField];
        if (aVal is Comparable && bVal is Comparable) {
          return _descending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
        }
        return 0;
      });
    }

    if (_limit != null && _limit! < results.length) {
      results = results.take(_limit!).toList();
    }

    return results;
  }

  Future<Map<String, dynamic>?> first() async {
    final results = await get();
    return results.isNotEmpty ? results.first : null;
  }
}
