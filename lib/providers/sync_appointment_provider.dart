import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_appointment.dart';
import '../services/sync_supabase_service.dart';

final syncServiceProvider = Provider((ref) {
  ref.keepAlive();
  return SyncSupabaseService();
});

final syncAppointmentsStreamProvider =
    StreamProvider<List<SyncAppointment>>((ref) {
  ref.keepAlive();
  return ref.read(syncServiceProvider).getAppointments();
});

final syncAppointmentsProvider = Provider<List<SyncAppointment>>((ref) {
  return ref.watch(syncAppointmentsStreamProvider).value ?? [];
});

final syncAppointmentActionsProvider = Provider((ref) {
  return SyncAppointmentActions(ref.watch(syncServiceProvider));
});

class SyncAppointmentActions {
  SyncAppointmentActions(this._service);

  final SyncSupabaseService _service;

  Future<void> updateAppointment(SyncAppointment updated) async {
    await _service.saveAppointment(updated);
  }

  Future<void> deleteAppointment(String id) async {
    await _service.deleteAppointment(id);
  }

  Future<void> addAppointment(SyncAppointment item) async {
    await _service.saveAppointment(item);
  }
}
