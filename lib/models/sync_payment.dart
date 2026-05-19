class SyncPaymentAllocation {
  final int appointmentId;
  final String date; // YYYY-MM-DD
  final int allocatedCents;

  SyncPaymentAllocation({
    required this.appointmentId,
    required this.date,
    required this.allocatedCents,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'date': date,
      'allocated_cents': allocatedCents,
    };
  }

  factory SyncPaymentAllocation.fromJson(Map<String, dynamic> json) {
    return SyncPaymentAllocation(
      appointmentId: json['appointment_id'] as int,
      date: json['date'] as String,
      allocatedCents: json['allocated_cents'] as int,
    );
  }
}

class SyncPayment {
  final int id;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paid_on': paidOn,
      'amount_cents': amountCents,
      'note': note,
      'user_id': userId,
      'appointments': appointments.map((a) => a.toJson()).toList(),
    };
  }

  factory SyncPayment.fromJson(Map<String, dynamic> json) {
    return SyncPayment(
      id: json['id'] as int,
      paidOn: json['paid_on'] as String,
      amountCents: json['amount_cents'] as int,
      note: json['note'] as String?,
      userId: json['user_id'] as int,
      appointments: (json['appointments'] as List<dynamic>)
          .map((a) => SyncPaymentAllocation.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
