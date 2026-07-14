import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planner_activity.dart';
import '../services/planner_service.dart';

final plannerServiceProvider = Provider((ref) => PlannerFirestoreService());

final plannerActivitiesStreamProvider =
    StreamProvider<List<PlannerActivity>>((ref) {
  ref.keepAlive();
  final service = ref.watch(plannerServiceProvider);
  return service.getActivities();
});

List<PlannerActivity> activitiesForDay(
  List<PlannerActivity> all,
  DateTime day,
) {
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  return all.where((activity) {
    return activity.startDateTime.isBefore(dayEnd) &&
        activity.endDateTime.isAfter(dayStart);
  }).toList();
}
