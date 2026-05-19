import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_appointment.dart';

final syncAppointmentsProvider = NotifierProvider<SyncAppointmentNotifier, List<SyncAppointment>>(
  SyncAppointmentNotifier.new,
);

class SyncAppointmentNotifier extends Notifier<List<SyncAppointment>> {
  @override
  List<SyncAppointment> build() {
    // Generate mock appointments for May 2026
    return [
      SyncAppointment(
        id: 1,
        date: '2026-05-02',
        status: 'svolto',
        priceCents: 5000,
        note: 'Prima seduta mensile, da saldare.',
        userId: 1,
      ),
      SyncAppointment(
        id: 2,
        date: '2026-05-08',
        status: 'pagato',
        priceCents: 5000,
        paidAt: '2026-05-09',
        note: 'Pagato tramite bonifico bancario.',
        userId: 1,
      ),
      SyncAppointment(
        id: 3,
        date: '2026-05-15',
        status: 'previsto',
        priceCents: 6000,
        overridePriceCents: 5500,
        note: 'Prezzo scontato concordato.',
        userId: 1,
      ),
      SyncAppointment(
        id: 4,
        date: '2026-05-19',
        status: 'previsto',
        priceCents: 5000,
        userId: 1,
      ),
      SyncAppointment(
        id: 5,
        date: '2026-05-22',
        status: 'annullato',
        priceCents: 5000,
        note: 'Paziente impossibilitato a partecipare.',
        userId: 1,
      ),
      SyncAppointment(
        id: 6,
        date: '2026-05-26',
        status: 'previsto',
        priceCents: 5000,
        userId: 1,
      ),
      SyncAppointment(
        id: 7,
        date: '2026-06-02',
        status: 'previsto',
        priceCents: 5000,
        userId: 1,
      ),
    ];
  }

  void updateAppointment(SyncAppointment updated) {
    state = [
      for (final a in state)
        if (a.id == updated.id) updated else a
    ];
  }

  void deleteAppointment(int id) {
    state = state.where((a) => a.id != id).toList();
  }

  void addAppointment(SyncAppointment item) {
    // Generate a new unique ID
    final newId = state.isEmpty ? 1 : state.map((a) => a.id).reduce((max, id) => id > max ? id : max) + 1;
    final newItem = item.copyWith(id: newId);
    state = [...state, newItem];
  }
}
