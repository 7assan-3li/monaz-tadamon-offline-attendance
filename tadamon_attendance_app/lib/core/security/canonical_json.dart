import 'dart:convert';

String encodeCanonicalJson(Map<String, Object?> payload) {
  Object? sortValue(Object? value) {
    if (value is List<Object?>) {
      return value.map(sortValue).toList(growable: false);
    }
    if (value is Map<String, Object?>) {
      final keys = value.keys.toList(growable: false)..sort();
      return <String, Object?>{
        for (final key in keys) key: sortValue(value[key]),
      };
    }
    return value;
  }

  return jsonEncode(sortValue(payload));
}
