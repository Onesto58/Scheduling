import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/routine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> scheduleRoutineNotifications(Routine routine) async {
    final morningSchedule = routine.getSchedule();
    final bedtimeSchedule = routine.getBedtimeSchedule();
    
    // Schedule Morning Tasks
    for (var i = 0; i < morningSchedule.length; i++) {
      final item = morningSchedule[i];
      final startTime = item['startTime'] as DateTime;
      final task = item['task'];

      if (startTime.isAfter(DateTime.now())) {
        await _notificationsPlugin.zonedSchedule(
          id: routine.id.hashCode + i,
          title: 'Ora di iniziare: ${task.title}',
          body: 'Il programma "${routine.name}" prosegue!',
          scheduledDate: tz.TZDateTime.from(startTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_channel',
              'Routine Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    // Schedule Bedtime Tasks
    for (var i = 0; i < bedtimeSchedule.length; i++) {
      final item = bedtimeSchedule[i];
      final startTime = item['startTime'] as DateTime;
      final task = item['task'];

      if (startTime.isAfter(DateTime.now())) {
        await _notificationsPlugin.zonedSchedule(
          id: routine.id.hashCode + i + 1000,
          title: 'Prep. Sonno: ${task.title}',
          body: 'Inizia la tua preparazione per dormire.',
          scheduledDate: tz.TZDateTime.from(startTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_channel',
              'Routine Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    // Schedule final departure notification
    if (routine.targetEndTime.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        id: routine.id.hashCode + 999,
        title: 'Tempo scaduto! È ora di uscire',
        body: 'La routine "${routine.name}" è completata.',
        scheduledDate: tz.TZDateTime.from(routine.targetEndTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'routine_channel',
            'Routine Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelRoutineNotifications(String routineId) async {
    // This is complex without a lookup table, but for now we'd cancel all or use pre-defined ID ranges
    // For this MVP, we'll focus on the core logic.
  }
}
