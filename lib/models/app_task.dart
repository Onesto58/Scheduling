
class AppTask {
  final String id;
  final String title;
  final Duration duration;
  final bool isCompleted;

  AppTask({
    required this.id,
    required this.title,
    required this.duration,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration.inMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory AppTask.fromMap(Map<String, dynamic> map) {
    return AppTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      duration: Duration(minutes: map['duration'] ?? 0),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  AppTask copyWith({
    String? id,
    String? title,
    Duration? duration,
    bool? isCompleted,
  }) {
    return AppTask(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
