import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_payment.dart';
import '../models/sync_appointment.dart';
import '../services/sync_supabase_service.dart';
import 'sync_appointment_provider.dart';

final syncPaymentsStreamProvider = StreamProvider<List<SyncPayment>>((ref) {
  ref.keepAlive();
  return ref.read(syncServiceProvider).getPayments();
});

final syncPaymentsProvider = Provider<List<SyncPayment>>((ref) {
  return ref.watch(syncPaymentsStreamProvider).value ?? [];
});

final syncPaymentActionsProvider = Provider((ref) {
  return SyncPaymentActions(
    ref.watch(syncServiceProvider),
    ref.watch(syncAppointmentActionsProvider),
  );
});

class SyncPaymentActions {
  SyncPaymentActions(this._service, this._appointmentActions);

  final SyncSupabaseService _service;
  final SyncAppointmentActions _appointmentActions;

  Future<String> registerPayment({
    required int userId,
    required String paidOn,
    required String? note,
    required List<SyncAppointment> selectedAppointments,
  }) async {
    final allocations = selectedAppointments.map((appt) {
      return SyncPaymentAllocation(
        appointmentId: appt.id,
        date: appt.date,
        allocatedCents: appt.effectivePriceCents,
      );
    }).toList();

    final totalAmount =
        allocations.fold<int>(0, (sum, alloc) => sum + alloc.allocatedCents);

    final newPayment = SyncPayment(
      id: '',
      paidOn: paidOn,
      amountCents: totalAmount,
      note: note,
      userId: userId,
      appointments: allocations,
    );

    for (final appt in selectedAppointments) {
      final updated = appt.copyWith(
        status: 'pagato',
        paidAt: () => paidOn,
        paidPriceCents: () => appt.effectivePriceCents,
      );
      await _appointmentActions.updateAppointment(updated);
    }

    return _service.savePayment(newPayment);
  }
}
