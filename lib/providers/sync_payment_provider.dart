import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_payment.dart';
import '../models/sync_appointment.dart';
import 'sync_appointment_provider.dart';

final syncPaymentsProvider = NotifierProvider<SyncPaymentNotifier, List<SyncPayment>>(
  SyncPaymentNotifier.new,
);

class SyncPaymentNotifier extends Notifier<List<SyncPayment>> {
  @override
  List<SyncPayment> build() {
    // Generate initial mock payment linked to appointment id 2
    return [
      SyncPayment(
        id: 1,
        paidOn: '2026-05-09',
        amountCents: 5000,
        note: 'Pagato tramite bonifico bancario.',
        userId: 1,
        appointments: [
          SyncPaymentAllocation(
            appointmentId: 2,
            date: '2026-05-08',
            allocatedCents: 5000,
          ),
        ],
      ),
    ];
  }

  int registerPayment({
    required int userId,
    required String paidOn,
    required String? note,
    required List<SyncAppointment> selectedAppointments,
  }) {
    // 1. Generate unique ID for the new payment
    final nextId = state.isEmpty ? 1 : state.map((p) => p.id).reduce((max, id) => id > max ? id : max) + 1;

    // 2. Create payment allocations
    final allocations = selectedAppointments.map((appt) {
      return SyncPaymentAllocation(
        appointmentId: appt.id,
        date: appt.date,
        allocatedCents: appt.effectivePriceCents,
      );
    }).toList();

    final totalAmount = allocations.fold<int>(0, (sum, alloc) => sum + alloc.allocatedCents);

    // 3. Create the SyncPayment object
    final newPayment = SyncPayment(
      id: nextId,
      paidOn: paidOn,
      amountCents: totalAmount,
      note: note,
      userId: userId,
      appointments: allocations,
    );

    // 4. Update the corresponding appointments status in the appointment provider
    final appointmentsNotifier = ref.read(syncAppointmentsProvider.notifier);
    for (final appt in selectedAppointments) {
      final updated = appt.copyWith(
        status: 'pagato',
        paidAt: () => paidOn,
        paidPriceCents: () => appt.effectivePriceCents,
      );
      appointmentsNotifier.updateAppointment(updated);
    }

    // 5. Save the payment record
    state = [...state, newPayment];

    return nextId;
  }
}
