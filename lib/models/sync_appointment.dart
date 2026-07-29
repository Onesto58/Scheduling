import '../utils/rtdb_parsing.dart';

class SyncAppointment {
  final String id;
  final String date; // YYYY-MM-DD
  final String status; // previsto, svolto, pagato, annullato
  final int priceCents;
  final int? overridePriceCents;
  final String? note;
  final String? paidAt;
  final int? paidPriceCents;
  final String? recurrenceId;
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
    String? id,
    String? date,
    String? status,
    int? priceCents,
    int? Function()? overridePriceCents,
    String? Function()? note,
    String? Function()? paidAt,
    int? Function()? paidPriceCents,
    String? Function()? recurrenceId,
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

  Map<String, dynamic> toMap() {
    return {
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

  factory SyncAppointment.fromMap(Map<String, dynamic> map, String docId) {
    return SyncAppointment(
      id: docId,
      date: rtdbParseString(map['date']),
      status: rtdbParseString(map['status'], defaultValue: 'previsto'),
      priceCents: rtdbParseInt(map['price_cents']),
      overridePriceCents: map['override_price_cents'] == null
          ? null
          : rtdbParseInt(map['override_price_cents']),
      note: map['note'] == null ? null : rtdbParseString(map['note']),
      paidAt: map['paid_at'] == null ? null : rtdbParseString(map['paid_at']),
      paidPriceCents: map['paid_price_cents'] == null
          ? null
          : rtdbParseInt(map['paid_price_cents']),
      recurrenceId: map['recurrence_id'] == null
          ? null
          : rtdbParseString(map['recurrence_id']),
      userId: rtdbParseInt(map['user_id'], defaultValue: 1),
    );
  }
}
