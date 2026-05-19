class SyncAppointment {
  final int id;
  final String date; // YYYY-MM-DD
  final String status; // previsto, svolto, pagato, annullato
  final int priceCents;
  final int? overridePriceCents;
  final String? note;
  final String? paidAt;
  final int? paidPriceCents;
  final int? recurrenceId;
  final int userId;

  SyncAppointment({
    required this.id,
    required this.date,
    required this.status,
    required this.priceCents,
    this.overridePriceCents,
    this.note,
    this.paidAt,
    this.paidPriceCents,
    this.recurrenceId,
    required this.userId,
  });

  int get effectivePriceCents => overridePriceCents ?? priceCents;

  SyncAppointment copyWith({
    int? id,
    String? date,
    String? status,
    int? priceCents,
    int? Function()? overridePriceCents,
    String? Function()? note,
    String? Function()? paidAt,
    int? Function()? paidPriceCents,
    int? Function()? recurrenceId,
    int? userId,
  }) {
    return SyncAppointment(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      priceCents: priceCents ?? this.priceCents,
      overridePriceCents: overridePriceCents != null ? overridePriceCents() : this.overridePriceCents,
      note: note != null ? note() : this.note,
      paidAt: paidAt != null ? paidAt() : this.paidAt,
      paidPriceCents: paidPriceCents != null ? paidPriceCents() : this.paidPriceCents,
      recurrenceId: recurrenceId != null ? recurrenceId() : this.recurrenceId,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'price_cents': priceCents,
      'override_price_cents': overridePriceCents,
      'note': note,
      'paid_at': paidAt,
      'paid_price_cents': paidPriceCents,
      'recurrence_id': recurrenceId,
      'user_id': userId,
    };
  }

  factory SyncAppointment.fromJson(Map<String, dynamic> json) {
    return SyncAppointment(
      id: json['id'] as int,
      date: json['date'] as String,
      status: json['status'] as String,
      priceCents: json['price_cents'] as int,
      overridePriceCents: json['override_price_cents'] as int?,
      note: json['note'] as String?,
      paidAt: json['paid_at'] as String?,
      paidPriceCents: json['paid_price_cents'] as int?,
      recurrenceId: json['recurrence_id'] as int?,
      userId: json['user_id'] as int,
    );
  }
}
