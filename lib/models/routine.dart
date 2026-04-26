import 'app_task.dart';

class Routine {
  final String id;
  final String name;
  final DateTime targetEndTime;
  final List<AppTask> tasks;
  final int sleepCycles;
  final List<AppTask> bedtimeTasks;

  Routine({
    required this.id,
    required this.name,
    required this.targetEndTime,
    required this.tasks,
    this.sleepCycles = 0,
    this.bedtimeTasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetEndTime': targetEndTime.toIso8601String(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'sleepCycles': sleepCycles,
      'bedtimeTasks': bedtimeTasks.map((t) => t.toMap()).toList(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map, String docId) {
    return Routine(
      id: docId,
      name: map['name'] ?? '',
      targetEndTime: DateTime.parse(map['targetEndTime'] ?? DateTime.now().toIso8601String()),
      tasks: (map['tasks'] as List? ?? [])
          .map((t) => AppTask.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
      sleepCycles: map['sleepCycles'] ?? 0,
      bedtimeTasks: (map['bedtimeTasks'] as List? ?? [])
          .map((t) => AppTask.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
    );
  }

  /// Calculates the schedule for each task in the routine.
  /// Returns a list of maps, each containing 'task', 'startTime', and 'endTime'.
  List<Map<String, dynamic>> getSchedule() {
    List<Map<String, dynamic>> schedule = [];
    DateTime lastEndTime = targetEndTime;

    // We iterate backwards through tasks to calculate start times
    for (var i = tasks.length - 1; i >= 0; i--) {
      final task = tasks[i];
      final startTime = lastEndTime.subtract(task.duration);
      
      schedule.insert(0, {
        'task': task,
        'startTime': startTime,
        'endTime': lastEndTime,
      });

      lastEndTime = startTime;
    }

    return schedule;
  }

  /// Calculates the schedule for bedtime tasks based on the morning routine start time.
  List<Map<String, dynamic>> getBedtimeSchedule() {
    if (sleepCycles == 0) return [];

    final morningSchedule = getSchedule();
    if (morningSchedule.isEmpty) return [];

    final wakeUpTime = morningSchedule.first['startTime'] as DateTime;
    final fallAsleepTime = wakeUpTime.subtract(Duration(minutes: sleepCycles * 90));

    List<Map<String, dynamic>> schedule = [];
    DateTime lastEndTime = fallAsleepTime;

    for (var i = bedtimeTasks.length - 1; i >= 0; i--) {
      final task = bedtimeTasks[i];
      final startTime = lastEndTime.subtract(task.duration);

      schedule.insert(0, {
        'task': task,
        'startTime': startTime,
        'endTime': lastEndTime,
      });

      lastEndTime = startTime;
    }

    return schedule;
  }

  Routine copyWith({
    String? id,
    String? name,
    DateTime? targetEndTime,
    List<AppTask>? tasks,
    int? sleepCycles,
    List<AppTask>? bedtimeTasks,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      targetEndTime: targetEndTime ?? this.targetEndTime,
      tasks: tasks ?? this.tasks,
      sleepCycles: sleepCycles ?? this.sleepCycles,
      bedtimeTasks: bedtimeTasks ?? this.bedtimeTasks,
    );
  }
}
