import 'package:flutter/foundation.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import '../models/routine.dart';

class WatchService {
  static final WatchService _instance = WatchService._internal();
  factory WatchService() => _instance;
  WatchService._internal();

  final _watch = WatchConnectivity();

  /// Sincronizza la routine corrente con l'Apple Watch
  Future<void> syncRoutine(Routine routine) async {
    try {
      final schedule = routine.getSchedule();
      final bedtime = routine.getBedtimeSchedule();

      final data = {
        'name': routine.name,
        'targetEndTime': routine.targetEndTime.toIso8601String(),
        'tasks': schedule.map((item) => {
          'title': item['task'].title,
          'startTime': (item['startTime'] as DateTime).toIso8601String(),
          'endTime': (item['endTime'] as DateTime).toIso8601String(),
          'duration': item['task'].duration.inMinutes,
        }).toList(),
        'bedtimeTasks': bedtime.map((item) => {
          'title': item['task'].title,
          'startTime': (item['startTime'] as DateTime).toIso8601String(),
          'endTime': (item['endTime'] as DateTime).toIso8601String(),
          'duration': item['task'].duration.inMinutes,
        }).toList(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      // updateApplicationContext è il modo più affidabile per inviare dati
      // che devono persistere sull'orologio anche se l'app viene chiusa.
      await _watch.updateApplicationContext(data);
      debugPrint('✅ Routine sincronizzata con Apple Watch');
    } catch (e) {
      debugPrint('❌ Errore durante la sincronizzazione con Watch: $e');
    }
  }
}
