import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utils/rtdb_parsing.dart';
import '../models/sync_appointment.dart';
import '../models/sync_payment.dart';
import '../models/sync_recurrence.dart';

class SyncRealtimeDatabaseService {
  static const databaseUrl =
      'https://scheduling-morning-default-rtdb.europe-west1.firebasedatabase.app';

  static const countersPath = 'db_psi_counters';
  static const appointmentsPath = 'db_psi_appointments';
  static const paymentsPath = 'db_psi_payments';
  static const recurrencesPath = 'db_psi_recurrences';
  static const priceRulesPath = 'db_psi_price_rules';

  final FirebaseDatabase _database;

  SyncRealtimeDatabaseService({FirebaseDatabase? database})
      : _database = database ??
            FirebaseDatabase.instanceFor(
              app: Firebase.app(),
              databaseURL: databaseUrl,
            );

  DatabaseReference _ref(String path) => _database.ref(path);

  Stream<List<SyncAppointment>> getAppointments() {
    return _ref(appointmentsPath).onValue.map((event) {
      return _parseList(event.snapshot, SyncAppointment.fromMap);
    });
  }

  Future<String> saveAppointment(SyncAppointment appointment) async {
    if (appointment.id.isEmpty) {
      final id = await _createNumericId('appointments', appointmentsPath);
      await _ref('$appointmentsPath/$id').set(appointment.toMap());
      return id;
    }
    await _ref('$appointmentsPath/${appointment.id}').set(appointment.toMap());
    return appointment.id;
  }

  Future<void> deleteAppointment(String id) async {
    await _ref('$appointmentsPath/$id').remove();
  }

  Stream<List<SyncPayment>> getPayments() {
    return _ref(paymentsPath).onValue.map((event) {
      return _parseList(event.snapshot, SyncPayment.fromMap);
    });
  }

  Future<String> savePayment(SyncPayment payment) async {
    if (payment.id.isEmpty) {
      final id = await _createNumericId('payments', paymentsPath);
      await _ref('$paymentsPath/$id').set(payment.toMap());
      return id;
    }
    await _ref('$paymentsPath/${payment.id}').set(payment.toMap());
    return payment.id;
  }

  Stream<List<SyncRecurrence>> getRecurrences() {
    return _ref(recurrencesPath).onValue.map((event) {
      return _parseList(event.snapshot, SyncRecurrence.fromMap);
    });
  }

  Future<String> saveRecurrence(SyncRecurrence recurrence) async {
    if (recurrence.id.isEmpty) {
      final id = await _createNumericId('recurrences', recurrencesPath);
      await _ref('$recurrencesPath/$id').set(recurrence.toMap());
      return id;
    }
    await _ref('$recurrencesPath/${recurrence.id}').set(recurrence.toMap());
    return recurrence.id;
  }

  Stream<List<SyncPriceRule>> getPriceRules() {
    return _ref(priceRulesPath).onValue.map((event) {
      return _parseList(event.snapshot, SyncPriceRule.fromMap);
    });
  }

  Future<String> savePriceRule(SyncPriceRule rule) async {
    if (rule.id.isEmpty) {
      final id = await _createNumericId('price_rules', priceRulesPath);
      await _ref('$priceRulesPath/$id').set(rule.toMap());
      return id;
    }
    await _ref('$priceRulesPath/${rule.id}').set(rule.toMap());
    return rule.id;
  }

  Future<String> _createNumericId(String counterKey, String collectionPath) async {
    await _ensureCounterInitialized(counterKey, collectionPath);

    final counterRef = _ref('$countersPath/$counterKey');
    final result = await counterRef.runTransaction((Object? current) {
      final next = ((current as num?)?.toInt() ?? 0) + 1;
      return Transaction.success(next);
    });

    return (result.snapshot.value as num).toInt().toString();
  }

  Future<void> _ensureCounterInitialized(
    String counterKey,
    String collectionPath,
  ) async {
    final counterRef = _ref('$countersPath/$counterKey');
    final counterSnapshot = await counterRef.get();
    if (counterSnapshot.exists && counterSnapshot.value != null) {
      return;
    }

    final maxExistingId = await _maxNumericKey(collectionPath);
    await counterRef.set(maxExistingId);
  }

  Future<int> _maxNumericKey(String collectionPath) async {
    final snapshot = await _ref(collectionPath).get();
    final value = snapshot.value;
    if (value == null || value is! Map) return 0;

    var maxId = 0;
    for (final key in value.keys) {
      final parsed = int.tryParse(key.toString());
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    return maxId;
  }

  List<T> _parseList<T>(
    DataSnapshot snapshot,
    T Function(Map<String, dynamic> map, String id) fromMap,
  ) {
    final entries = rtdbParseEntries(snapshot.value)
      ..sort((a, b) {
        final aNum = int.tryParse(a.key) ?? 0;
        final bNum = int.tryParse(b.key) ?? 0;
        return aNum.compareTo(bNum);
      });

    final items = <T>[];
    for (final entry in entries) {
      try {
        items.add(fromMap(entry.value, entry.key));
      } catch (_) {
        // Skip malformed nodes instead of breaking the whole stream.
      }
    }
    return items;
  }
}
