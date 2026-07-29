import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_recurrence.dart';
import '../models/sync_appointment.dart';
import '../services/sync_supabase_service.dart';
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

final syncRecurrencesStreamProvider =
    StreamProvider<List<SyncRecurrence>>((ref) {
  ref.keepAlive();
  return ref.read(syncServiceProvider).getRecurrences();
});

final syncPriceRulesStreamProvider =
    StreamProvider<List<SyncPriceRule>>((ref) {
  ref.keepAlive();
  return ref.read(syncServiceProvider).getPriceRules();
});

final syncRecurrencesProvider = Provider<SyncRecurrenceState>((ref) {
  final recurrences = ref.watch(syncRecurrencesStreamProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <SyncRecurrence>[],
      );
  final priceRules = ref.watch(syncPriceRulesStreamProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <SyncPriceRule>[],
      );
  return SyncRecurrenceState(recurrences: recurrences, priceRules: priceRules);
});

final syncRecurrencesLoadStateProvider = Provider<AsyncValue<void>>((ref) {
  ref.watch(syncRecurrencesStreamProvider);
  ref.watch(syncPriceRulesStreamProvider);
  final recurrencesAsync = ref.watch(syncRecurrencesStreamProvider);
  final priceRulesAsync = ref.watch(syncPriceRulesStreamProvider);

  if (recurrencesAsync.hasError) {
    return AsyncValue.error(
      recurrencesAsync.error!,
      recurrencesAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (priceRulesAsync.hasError) {
    return AsyncValue.error(
      priceRulesAsync.error!,
      priceRulesAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (recurrencesAsync.isLoading || priceRulesAsync.isLoading) {
    return const AsyncValue.loading();
  }
  return const AsyncValue.data(null);
});

final syncRecurrenceActionsProvider = Provider((ref) {
  return SyncRecurrenceActions(
    ref.watch(syncServiceProvider),
    ref.watch(syncAppointmentActionsProvider),
    ref,
  );
});

class SyncRecurrenceActions {
  SyncRecurrenceActions(this._service, this._appointmentActions, this._ref);

  final SyncSupabaseService _service;
  final SyncAppointmentActions _appointmentActions;
  final Ref _ref;

  Future<void> addRecurrence(String title, int weekday) async {
    final newRec = SyncRecurrence(
      id: '',
      title: title,
      weekday: weekday,
      isActive: true,
    );
    final recurrenceId = await _service.saveRecurrence(newRec);

    final todayStr = DateTime.now().toString().split(' ')[0];
    final newRule = SyncPriceRule(
      id: '',
      recurrenceId: recurrenceId,
      effectiveFrom: todayStr,
      priceCents: 5000,
    );
    await _service.savePriceRule(newRule);
  }

  Future<void> toggleRecurrence(String id) async {
    final state = _ref.read(syncRecurrencesProvider);
    final recurrence = state.recurrences.firstWhere((r) => r.id == id);
    await _service.saveRecurrence(recurrence.copyWith(isActive: !recurrence.isActive));
  }

  Future<void> addPriceRule(
    String recurrenceId,
    String effectiveFrom,
    int priceCents,
  ) async {
    final newRule = SyncPriceRule(
      id: '',
      recurrenceId: recurrenceId,
      effectiveFrom: effectiveFrom,
      priceCents: priceCents,
    );
    await _service.savePriceRule(newRule);
  }

  int getActivePrice(String recurrenceId, String dateStr) {
    final priceRules = _ref.read(syncRecurrencesProvider).priceRules;
    final rules =
        priceRules.where((r) => r.recurrenceId == recurrenceId).toList();
    if (rules.isEmpty) return 5000;

    final effectiveRules =
        rules.where((r) => r.effectiveFrom.compareTo(dateStr) <= 0).toList();
    if (effectiveRules.isEmpty) {
      rules.sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
      return rules.first.priceCents;
    }

    effectiveRules.sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    return effectiveRules.first.priceCents;
  }

  Future<int> generateAppointmentsFrom(String startDateStr, int months) async {
    final state = _ref.read(syncRecurrencesProvider);
    final currentAppointments = _ref.read(syncAppointmentsProvider);
    final startDate = DateTime.parse(startDateStr);
    final endDate = startDate.add(Duration(days: months * 30));

    int createdCount = 0;

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final weekday = date.weekday;

      final activeRecs = state.recurrences
          .where((r) => r.weekday == weekday && r.isActive)
          .toList();

      for (final rec in activeRecs) {
        final exists = currentAppointments.any(
          (a) => a.date == dateStr && a.recurrenceId == rec.id,
        );
        if (!exists) {
          final price = getActivePrice(rec.id, dateStr);
          final newAppt = SyncAppointment(
            id: '',
            date: dateStr,
            status: 'previsto',
            priceCents: price,
            recurrenceId: rec.id,
            userId: 1,
          );
          await _appointmentActions.addAppointment(newAppt);
          createdCount++;
        }
      }
    }

    return createdCount;
  }

  Future<int> extendTo30MonthsFromToday() async {
    final todayStr = DateTime.now().toString().split(' ')[0];
    return generateAppointmentsFrom(todayStr, 30);
  }
}
