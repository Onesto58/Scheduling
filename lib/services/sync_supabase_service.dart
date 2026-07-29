import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sync_appointment.dart';
import '../models/sync_payment.dart';
import '../models/sync_recurrence.dart';

class SyncSupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  static const String appointmentsTable = 'db_psi_appointments';
  static const String paymentsTable = 'db_psi_payments';
  static const String recurrencesTable = 'db_psi_recurrences';
  static const String priceRulesTable = 'db_psi_price_rules';

  // --- Appointments ---
  Stream<List<SyncAppointment>> getAppointments() {
    return _client
        .from(appointmentsTable)
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .map((list) {
          return list.map((item) {
            final docId = item['id'].toString();
            return SyncAppointment.fromMap(item, docId);
          }).toList();
        });
  }

  Future<String> saveAppointment(SyncAppointment appointment) async {
    final map = appointment.toMap();
    if (map['recurrence_id'] != null && map['recurrence_id'] is String) {
      map['recurrence_id'] = int.tryParse(map['recurrence_id']);
    }

    if (appointment.id.isEmpty) {
      final res = await _client
          .from(appointmentsTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(appointment.id);
      await _client.from(appointmentsTable).update(map).eq('id', intId);
      return appointment.id;
    }
  }

  Future<void> deleteAppointment(String id) async {
    final intId = int.parse(id);
    await _client.from(appointmentsTable).delete().eq('id', intId);
  }

  // --- Payments ---
  Stream<List<SyncPayment>> getPayments() {
    return _client
        .from(paymentsTable)
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .map((list) {
          return list.map((item) {
            final docId = item['id'].toString();
            return SyncPayment.fromMap(item, docId);
          }).toList();
        });
  }

  Future<String> savePayment(SyncPayment payment) async {
    final map = payment.toMap();
    if (payment.id.isEmpty) {
      final res = await _client
          .from(paymentsTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(payment.id);
      await _client.from(paymentsTable).update(map).eq('id', intId);
      return payment.id;
    }
  }

  // --- Recurrences ---
  Stream<List<SyncRecurrence>> getRecurrences() {
    return _client
        .from(recurrencesTable)
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .map((list) {
          return list.map((item) {
            final docId = item['id'].toString();
            return SyncRecurrence.fromMap(item, docId);
          }).toList();
        });
  }

  Future<String> saveRecurrence(SyncRecurrence recurrence) async {
    final map = recurrence.toMap();
    if (recurrence.id.isEmpty) {
      final res = await _client
          .from(recurrencesTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(recurrence.id);
      await _client.from(recurrencesTable).update(map).eq('id', intId);
      return recurrence.id;
    }
  }

  // --- Price Rules ---
  Stream<List<SyncPriceRule>> getPriceRules() {
    return _client
        .from(priceRulesTable)
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .map((list) {
          return list.map((item) {
            final docId = item['id'].toString();
            return SyncPriceRule.fromMap(item, docId);
          }).toList();
        });
  }

  Future<String> savePriceRule(SyncPriceRule rule) async {
    final map = rule.toMap();
    if (map['recurrence_id'] != null && map['recurrence_id'] is String) {
      map['recurrence_id'] = int.tryParse(map['recurrence_id']);
    }

    if (rule.id.isEmpty) {
      final res = await _client
          .from(priceRulesTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(rule.id);
      await _client.from(priceRulesTable).update(map).eq('id', intId);
      return rule.id;
    }
  }
}
