class SyncRecurrence {
  final int id;
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
    int? id,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weekday': weekday,
      'is_active': isActive,
    };
  }

  factory SyncRecurrence.fromJson(Map<String, dynamic> json) {
    return SyncRecurrence(
      id: json['id'] as int,
      title: json['title'] as String,
      weekday: json['weekday'] as int,
      isActive: json['is_active'] as bool,
    );
  }
}

class SyncPriceRule {
  final int id;
  final int recurrenceId;
  final String effectiveFrom; // YYYY-MM-DD
  final int priceCents;

  SyncPriceRule({
    required this.id,
    required this.recurrenceId,
    required this.effectiveFrom,
    required this.priceCents,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recurrence_id': recurrenceId,
      'effective_from': effectiveFrom,
      'price_cents': priceCents,
    };
  }

  factory SyncPriceRule.fromJson(Map<String, dynamic> json) {
    return SyncPriceRule(
      id: json['id'] as int,
      recurrenceId: json['recurrence_id'] as int,
      effectiveFrom: json['effective_from'] as String,
      priceCents: json['price_cents'] as int,
    );
  }
}
