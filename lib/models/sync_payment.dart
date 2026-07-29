import '../utils/rtdb_parsing.dart';

class SyncPaymentAllocation {
  final String appointmentId;
  final String date; // YYYY-MM-DD
  final int allocatedCents;

  SyncPaymentAllocation({
    required this.appointmentId,
    required this.date,
    required this.allocatedCents,
  });

  Map<String, dynamic> toMap() {
    return {
      'appointment_id': appointmentId,
      'date': date,
      'allocated_cents': allocatedCents,
    };
  }

  factory SyncPaymentAllocation.fromMap(Map<String, dynamic> map) {
    return SyncPaymentAllocation(
      appointmentId: rtdbParseString(map['appointment_id']),
      date: rtdbParseString(map['date']),
      allocatedCents: rtdbParseInt(map['allocated_cents']),
    );
  }
}

class SyncPayment {
  final String id;
  final String paidOn; // YYYY-MM-DD
  final int amountCents;
  final String? note;
  final int userId;
  final List<SyncPaymentAllocation> appointments;

  SyncPayment({
    required this.id,
    required this.paidOn,
    required this.amountCents,
    this.note,
    required this.userId,
    required this.appointments,
  });

  Map<String, dynamic> toMap() {
    return {
      'paid_on': paidOn,
      'amount_cents': amountCents,
      'note': note,
      'user_id': userId,
      'appointments': appointments.map((a) => a.toMap()).toList(),
    };
  }

  factory SyncPayment.fromMap(Map<String, dynamic> map, String docId) {
    return SyncPayment(
      id: docId,
      paidOn: rtdbParseString(map['paid_on']),
      amountCents: rtdbParseInt(map['amount_cents']),
      note: map['note'] == null ? null : rtdbParseString(map['note']),
      userId: rtdbParseInt(map['user_id'], defaultValue: 1),
      appointments: (map['appointments'] as List<dynamic>? ?? [])
          .map((a) => SyncPaymentAllocation.fromMap(
                rtdbToStringKeyMap(a),
              ))
          .toList(),
    );
  }
}
