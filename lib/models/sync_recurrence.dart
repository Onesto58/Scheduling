import '../utils/rtdb_parsing.dart';

class SyncRecurrence {
  final String id;
  final String title;
  final int weekday; // 1 = Monday, 7 = Sunday
  final bool isActive;

  SyncRecurrence({
    required this.id,
    required this.title,
    required this.weekday,
    required this.isActive,
  });

  SyncRecurrence copyWith({
    String? id,
    String? title,
    int? weekday,
    bool? isActive,
  }) {
    return SyncRecurrence(
      id: id ?? this.id,
      title: title ?? this.title,
      weekday: weekday ?? this.weekday,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'weekday': weekday,
      'is_active': isActive,
    };
  }

  factory SyncRecurrence.fromMap(Map<String, dynamic> map, String docId) {
    return SyncRecurrence(
      id: docId,
      title: rtdbParseString(map['title']),
      weekday: rtdbParseInt(map['weekday'], defaultValue: 1),
      isActive: rtdbParseBool(map['is_active']),
    );
  }
}

class SyncPriceRule {
  final String id;
  final String recurrenceId;
  final String effectiveFrom; // YYYY-MM-DD
  final int priceCents;

  SyncPriceRule({
    required this.id,
    required this.recurrenceId,
    required this.effectiveFrom,
    required this.priceCents,
  });

  Map<String, dynamic> toMap() {
    return {
      'recurrence_id': recurrenceId,
      'effective_from': effectiveFrom,
      'price_cents': priceCents,
    };
  }

  factory SyncPriceRule.fromMap(Map<String, dynamic> map, String docId) {
    return SyncPriceRule(
      id: docId,
      recurrenceId: rtdbParseString(map['recurrence_id']),
      effectiveFrom: rtdbParseString(map['effective_from']),
      priceCents: rtdbParseInt(map['price_cents']),
    );
  }
}
