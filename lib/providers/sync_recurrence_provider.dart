import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_recurrence.dart';
import '../models/sync_appointment.dart';
import 'sync_appointment_provider.dart';

class SyncRecurrenceState {
  final List<SyncRecurrence> recurrences;
  final List<SyncPriceRule> priceRules;

  SyncRecurrenceState({
    required this.recurrences,
    required this.priceRules,
  });

  SyncRecurrenceState copyWith({
    List<SyncRecurrence>? recurrences,
    List<SyncPriceRule>? priceRules,
  }) {
    return SyncRecurrenceState(
      recurrences: recurrences ?? this.recurrences,
      priceRules: priceRules ?? this.priceRules,
    );
  }
}

final syncRecurrencesProvider = NotifierProvider<SyncRecurrenceNotifier, SyncRecurrenceState>(
  SyncRecurrenceNotifier.new,
);

class SyncRecurrenceNotifier extends Notifier<SyncRecurrenceState> {
  @override
  SyncRecurrenceState build() {
    // Generate initial mock recurrences and price rules
    final recurrences = [
      SyncRecurrence(id: 1, title: 'Seduta di psicoterapia', weekday: 2, isActive: true), // Martedì
      SyncRecurrence(id: 2, title: 'Consulenza settimanale', weekday: 4, isActive: true), // Giovedì
    ];

    final priceRules = [
      SyncPriceRule(id: 1, recurrenceId: 1, effectiveFrom: '2026-01-01', priceCents: 5000), // 50€
      SyncPriceRule(id: 2, recurrenceId: 1, effectiveFrom: '2026-05-10', priceCents: 6000), // 60€
      SyncPriceRule(id: 3, recurrenceId: 2, effectiveFrom: '2026-01-01', priceCents: 7500), // 75€
    ];

    return SyncRecurrenceState(recurrences: recurrences, priceRules: priceRules);
  }

  void addRecurrence(String title, int weekday) {
    final nextId = state.recurrences.isEmpty ? 1 : state.recurrences.map((r) => r.id).reduce((max, id) => id > max ? id : max) + 1;
    final newRec = SyncRecurrence(id: nextId, title: title, weekday: weekday, isActive: true);
    
    // Add default price rule starting today
    final todayStr = DateTime.now().toString().split(" ")[0];
    final nextPriceRuleId = state.priceRules.isEmpty ? 1 : state.priceRules.map((p) => p.id).reduce((max, id) => id > max ? id : max) + 1;
    final newRule = SyncPriceRule(id: nextPriceRuleId, recurrenceId: nextId, effectiveFrom: todayStr, priceCents: 5000);

    state = state.copyWith(
      recurrences: [...state.recurrences, newRec],
      priceRules: [...state.priceRules, newRule],
    );
  }

  void toggleRecurrence(int id) {
    state = state.copyWith(
      recurrences: state.recurrences.map((r) {
        if (r.id == id) {
          return r.copyWith(isActive: !r.isActive);
        }
        return r;
      }).toList(),
    );
  }

  void addPriceRule(int recurrenceId, String effectiveFrom, int priceCents) {
    final nextId = state.priceRules.isEmpty ? 1 : state.priceRules.map((p) => p.id).reduce((max, id) => id > max ? id : max) + 1;
    final newRule = SyncPriceRule(
      id: nextId,
      recurrenceId: recurrenceId,
      effectiveFrom: effectiveFrom,
      priceCents: priceCents,
    );

    state = state.copyWith(
      priceRules: [...state.priceRules, newRule],
    );
  }

  int getActivePrice(int recurrenceId, String dateStr) {
    final rules = state.priceRules.where((r) => r.recurrenceId == recurrenceId).toList();
    if (rules.isEmpty) return 5000;

    // Filter rules effective on or before dateStr
    final effectiveRules = rules.where((r) => r.effectiveFrom.compareTo(dateStr) <= 0).toList();
    if (effectiveRules.isEmpty) {
      // If none effective yet, return the earliest price rule
      rules.sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
      return rules.first.priceCents;
    }

    // Sort by effectiveFrom descending and get the first
    effectiveRules.sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    return effectiveRules.first.priceCents;
  }

  int generateAppointmentsFrom(String startDateStr, int months) {
    final startDate = DateTime.parse(startDateStr);
    final endDate = startDate.add(Duration(days: months * 30));
    final appointmentsNotifier = ref.read(syncAppointmentsProvider.notifier);
    final currentAppointments = ref.read(syncAppointmentsProvider);

    int createdCount = 0;

    // Loop through days
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final weekday = date.weekday; // 1 = Monday, 7 = Sunday

      // Find active recurrences matching this day of week
      final activeRecs = state.recurrences.where((r) => r.weekday == weekday && r.isActive).toList();

      for (final rec in activeRecs) {
        // Check if an appointment already exists on this date
        final exists = currentAppointments.any((a) => a.date == dateStr && a.recurrenceId == rec.id);
        if (!exists) {
          final price = getActivePrice(rec.id, dateStr);
          final newAppt = SyncAppointment(
            id: 0, // Assigned inside provider
            date: dateStr,
            status: 'previsto',
            priceCents: price,
            recurrenceId: rec.id,
            userId: 1,
          );
          appointmentsNotifier.addAppointment(newAppt);
          createdCount++;
        }
      }
    }

    return createdCount;
  }

  int extendTo30MonthsFromToday() {
    final todayStr = DateTime.now().toString().split(" ")[0];
    return generateAppointmentsFrom(todayStr, 30);
  }
}
