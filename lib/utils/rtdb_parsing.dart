Map<String, dynamic> rtdbToStringKeyMap(Object? value) {
  if (value is! Map) return {};
  return value.map(
    (key, val) => MapEntry(key.toString(), val),
  );
}

bool rtdbParseBool(dynamic value, {bool defaultValue = true}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return defaultValue;
}

String rtdbParseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

int rtdbParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

List<MapEntry<String, Map<String, dynamic>>> rtdbParseEntries(
  Object? value,
) {
  if (value == null) return [];

  if (value is List) {
    return value.asMap().entries.map((entry) {
      final id = (entry.key + 1).toString();
      final data = rtdbToStringKeyMap(entry.value);
      return MapEntry(id, data);
    }).where((entry) => entry.value.isNotEmpty).toList();
  }

  if (value is Map) {
    return value.entries.map((entry) {
      final id = entry.key.toString();
      final data = rtdbToStringKeyMap(entry.value);
      return MapEntry(id, data);
    }).toList();
  }

  return [];
}
