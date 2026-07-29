import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sync_appointment.dart';
import '../models/sync_payment.dart';
import '../models/sync_recurrence.dart';

class SyncSupabaseService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static const String appointmentsTable = 'db_psi_appointments';
  static const String paymentsTable = 'db_psi_payments';
  static const String recurrencesTable = 'db_psi_recurrences';
  static const String priceRulesTable = 'db_psi_price_rules';

  // --- Appointments ---
  Stream<List<SyncAppointment>> getAppointments() {
    final client = _client;
    if (client == null) return Stream.value([]);
    return client
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
    final client = _client;
    if (client == null) throw Exception('Supabase non è stato inizializzato. Verificare le chiavi SUPABASE_URL e SUPABASE_ANON_KEY.');

    final map = appointment.toMap();
    if (map['recurrence_id'] != null && map['recurrence_id'] is String) {
      map['recurrence_id'] = int.tryParse(map['recurrence_id']);
    }

    if (appointment.id.isEmpty) {
      final res = await client
          .from(appointmentsTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(appointment.id);
      await client.from(appointmentsTable).update(map).eq('id', intId);
      return appointment.id;
    }
  }

  Future<void> deleteAppointment(String id) async {
    final client = _client;
    if (client == null) return;
    final intId = int.parse(id);
    await client.from(appointmentsTable).delete().eq('id', intId);
  }

  // --- Payments ---
  Stream<List<SyncPayment>> getPayments() {
    final client = _client;
    if (client == null) return Stream.value([]);
    return client
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
    final client = _client;
    if (client == null) throw Exception('Supabase non è stato inizializzato. Verificare le chiavi SUPABASE_URL e SUPABASE_ANON_KEY.');

    final map = payment.toMap();
    if (payment.id.isEmpty) {
      final res = await client
          .from(paymentsTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(payment.id);
      await client.from(paymentsTable).update(map).eq('id', intId);
      return payment.id;
    }
  }

  // --- Recurrences ---
  Stream<List<SyncRecurrence>> getRecurrences() {
    final client = _client;
    if (client == null) return Stream.value([]);
    return client
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
    final client = _client;
    if (client == null) throw Exception('Supabase non è stato inizializzato. Verificare le chiavi SUPABASE_URL e SUPABASE_ANON_KEY.');

    final map = recurrence.toMap();
    if (recurrence.id.isEmpty) {
      final res = await client
          .from(recurrencesTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(recurrence.id);
      await client.from(recurrencesTable).update(map).eq('id', intId);
      return recurrence.id;
    }
  }

  // --- Price Rules ---
  Stream<List<SyncPriceRule>> getPriceRules() {
    final client = _client;
    if (client == null) return Stream.value([]);
    return client
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
    final client = _client;
    if (client == null) throw Exception('Supabase non è stato inizializzato. Verificare le chiavi SUPABASE_URL e SUPABASE_ANON_KEY.');

    final map = rule.toMap();
    if (map['recurrence_id'] != null && map['recurrence_id'] is String) {
      map['recurrence_id'] = int.tryParse(map['recurrence_id']);
    }

    if (rule.id.isEmpty) {
      final res = await client
          .from(priceRulesTable)
          .insert(map)
          .select('id')
          .single();
      return res['id'].toString();
    } else {
      final intId = int.parse(rule.id);
      await client.from(priceRulesTable).update(map).eq('id', intId);
      return rule.id;
    }
  }
}
