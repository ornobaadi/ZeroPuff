import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/calculations/progress_calculations.dart';
import '../../repositories/notification_preferences_repository.dart';

class NotificationService {
  const NotificationService._();

  static const int dailyCheckInId = 1001;
  static const int milestoneReminderId = 1002;
  static const int streakProtectionId = 1003;

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings: settings);
  }

  static Future<bool> requestPermission() async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;

    final ios = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;

    return androidGranted && iosGranted;
  }

  static Future<void> reschedule({
    required NotificationPreferences preferences,
    DateTime? quitDate,
  }) async {
    await cancelScheduledReminders();

    if (preferences.dailyCheckInEnabled) {
      await _scheduleDaily(
        id: dailyCheckInId,
        hour: preferences.dailyCheckInHour,
        minute: preferences.dailyCheckInMinute,
        title: 'A quiet check-in?',
        body: 'One honest tap is enough for today.',
      );
    }

    if (preferences.streakProtectionEnabled) {
      await _scheduleDaily(
        id: streakProtectionId,
        hour: 23,
        minute: 0,
        title: 'Keep today recorded',
        body: 'Log a check-in or cigarette so your timeline stays honest.',
      );
    }

    if (preferences.milestoneReminderEnabled && quitDate != null) {
      final now = DateTime.now();
      final smokeFreeDuration = now.isBefore(quitDate)
          ? Duration.zero
          : now.difference(quitDate);
      final nextMilestone = ProgressCalculations.nextMilestone(
        smokeFreeDuration,
      );
      final milestoneAt = nextMilestone == null
          ? null
          : quitDate.add(nextMilestone.duration);

      if (nextMilestone != null &&
          milestoneAt != null &&
          milestoneAt.isAfter(now)) {
        await plugin.zonedSchedule(
          id: milestoneReminderId,
          title: '${nextMilestone.title} smoke-free',
          body: nextMilestone.body,
          scheduledDate: tz.TZDateTime.from(milestoneAt, tz.local),
          notificationDetails: _details(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> cancelScheduledReminders() async {
    await plugin.cancel(id: dailyCheckInId);
    await plugin.cancel(id: milestoneReminderId);
    await plugin.cancel(id: streakProtectionId);
  }

  static Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextTime(hour: hour, minute: minute),
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextTime({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      'zeropuff_reminders',
      'ZeroPuff reminders',
      channelDescription: 'Daily check-ins and gentle quit-plan reminders.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }
}
