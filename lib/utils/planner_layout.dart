import '../models/planner_activity.dart';

class PlannerLayoutItem {
  final PlannerActivity activity;
  final DateTime displayStart;
  final DateTime displayEnd;
  int column = 0;
  int totalColumns = 1;

  PlannerLayoutItem({
    required this.activity,
    required this.displayStart,
    required this.displayEnd,
  });
}

List<PlannerLayoutItem> computeDayLayout(
  List<PlannerActivity> activities,
  DateTime day,
) {
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final items = <PlannerLayoutItem>[];
  for (final activity in activities) {
    final start = activity.startDateTime.isBefore(dayStart)
        ? dayStart
        : activity.startDateTime;
    final end =
        activity.endDateTime.isAfter(dayEnd) ? dayEnd : activity.endDateTime;
    if (!start.isBefore(end)) continue;
    items.add(PlannerLayoutItem(
      activity: activity,
      displayStart: start,
      displayEnd: end,
    ));
  }

  if (items.isEmpty) return items;

  items.sort((a, b) {
    final cmp = a.displayStart.compareTo(b.displayStart);
    if (cmp != 0) return cmp;
    return b.displayEnd.compareTo(a.displayEnd);
  });

  final clusters = <List<PlannerLayoutItem>>[];
  var currentCluster = <PlannerLayoutItem>[items.first];
  var clusterEnd = items.first.displayEnd;

  for (var i = 1; i < items.length; i++) {
    final item = items[i];
    if (item.displayStart.isBefore(clusterEnd)) {
      currentCluster.add(item);
      if (item.displayEnd.isAfter(clusterEnd)) {
        clusterEnd = item.displayEnd;
      }
    } else {
      clusters.add(currentCluster);
      currentCluster = [item];
      clusterEnd = item.displayEnd;
    }
  }
  clusters.add(currentCluster);

  for (final cluster in clusters) {
    _assignColumns(cluster);
  }

  return items;
}

void _assignColumns(List<PlannerLayoutItem> cluster) {
  final columns = <List<PlannerLayoutItem>>[];

  for (final item in cluster) {
    var placed = false;
    for (var col = 0; col < columns.length; col++) {
      final last = columns[col].last;
      if (!item.displayStart.isBefore(last.displayEnd)) {
        columns[col].add(item);
        item.column = col;
        placed = true;
        break;
      }
    }
    if (!placed) {
      item.column = columns.length;
      columns.add([item]);
    }
  }

  final total = columns.length;
  for (final item in cluster) {
    item.totalColumns = total;
  }
}
