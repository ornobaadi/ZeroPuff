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
  static const int _dailyCheckInBaseId = 1100;
  static const int _streakProtectionBaseId = 1200;
  static const int _rollingReminderDays = 7;

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
    NotificationScheduleSnapshot snapshot =
        const NotificationScheduleSnapshot(),
  }) async {
    await cancelScheduledReminders();

    if (preferences.dailyCheckInEnabled) {
      final copy = _dailyCheckInCopy(snapshot);
      await _scheduleRollingOneShots(
        baseId: _dailyCheckInBaseId,
        hour: preferences.dailyCheckInHour,
        minute: preferences.dailyCheckInMinute,
        skipToday: snapshot.todayCheckedIn,
        title: copy.title,
        body: copy.body,
      );
    }

    if (preferences.streakProtectionEnabled) {
      final copy = _streakProtectionCopy(snapshot);
      await _scheduleRollingOneShots(
        baseId: _streakProtectionBaseId,
        hour: 22,
        minute: 15,
        skipToday: snapshot.todayCheckedIn,
        title: copy.title,
        body: copy.body,
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
    for (var index = 0; index < _rollingReminderDays; index++) {
      await plugin.cancel(id: _dailyCheckInBaseId + index);
      await plugin.cancel(id: _streakProtectionBaseId + index);
    }
  }

  static Future<void> _scheduleRollingOneShots({
    required int baseId,
    required int hour,
    required int minute,
    required bool skipToday,
    required String title,
    required String body,
  }) async {
    final firstOffset = _firstReminderOffset(
      hour: hour,
      minute: minute,
      skipToday: skipToday,
    );
    for (var index = 0; index < _rollingReminderDays; index++) {
      await plugin.zonedSchedule(
        id: baseId + index,
        title: title,
        body: body,
        scheduledDate: _timeOnDayOffset(
          hour: hour,
          minute: minute,
          daysFromToday: firstOffset + index,
        ),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static int _firstReminderOffset({
    required int hour,
    required int minute,
    required bool skipToday,
  }) {
    if (skipToday) {
      return 1;
    }
    final nextToday = _timeOnDayOffset(
      hour: hour,
      minute: minute,
      daysFromToday: 0,
    );
    return nextToday.isAfter(tz.TZDateTime.now(tz.local)) ? 0 : 1;
  }

  static tz.TZDateTime _timeOnDayOffset({
    required int hour,
    required int minute,
    required int daysFromToday,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: daysFromToday));
  }

  static _NotificationCopy _dailyCheckInCopy(
    NotificationScheduleSnapshot snapshot,
  ) {
    final progress = _progressLine(snapshot);
    if (snapshot.smokeFreeStreakDays >= 2) {
      return _NotificationCopy(
        title: 'Protect your ${snapshot.smokeFreeStreakDays}-day streak',
        body: '$progress One quick check-in keeps the record yours.',
      );
    }
    if (snapshot.moneySaved >= 1) {
      return _NotificationCopy(
        title: 'You have saved ${_money(snapshot)} so far',
        body:
            'Log today before the day gets noisy. Your progress is adding up.',
      );
    }
    if (snapshot.cigarettesAvoided > 0) {
      return _NotificationCopy(
        title: '${snapshot.cigarettesAvoided} cigarettes not smoked',
        body: 'Mark today honestly and keep that number moving.',
      );
    }
    return const _NotificationCopy(
      title: 'One honest check-in',
      body: 'No judgement. Just mark what happened and keep going.',
    );
  }

  static _NotificationCopy _streakProtectionCopy(
    NotificationScheduleSnapshot snapshot,
  ) {
    if (snapshot.smokeFreeStreakDays >= 2) {
      return _NotificationCopy(
        title: 'Do not leave today blank',
        body:
            'Your ${snapshot.smokeFreeStreakDays}-day streak deserves one honest tap before bed.',
      );
    }
    if (snapshot.moneySaved >= 1) {
      return _NotificationCopy(
        title: 'Close the day with proof',
        body:
            'You have kept ${_money(snapshot)} away from cigarettes. Record today in ZeroPuff.',
      );
    }
    return const _NotificationCopy(
      title: 'Close today gently',
      body: 'A check-in or log keeps your timeline honest. That is enough.',
    );
  }

  static String _progressLine(NotificationScheduleSnapshot snapshot) {
    if (snapshot.moneySaved >= 1) {
      return '${_money(snapshot)} saved.';
    }
    if (snapshot.cigarettesAvoided > 0) {
      return '${snapshot.cigarettesAvoided} cigarettes avoided.';
    }
    final smokeFree = _durationLabel(snapshot.smokeFreeDuration);
    if (smokeFree != null) {
      return '$smokeFree smoke-free.';
    }
    return 'Your progress still counts.';
  }

  static String _money(NotificationScheduleSnapshot snapshot) {
    final amount = snapshot.moneySaved >= 100
        ? snapshot.moneySaved.toStringAsFixed(0)
        : snapshot.moneySaved.toStringAsFixed(
            snapshot.moneySaved.truncateToDouble() == snapshot.moneySaved
                ? 0
                : 2,
          );
    return '${snapshot.currencySymbol}$amount';
  }

  static String? _durationLabel(Duration duration) {
    if (duration.inDays >= 1) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
    }
    if (duration.inHours >= 1) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
    }
    if (duration.inMinutes >= 20) {
      return '${duration.inMinutes} minutes';
    }
    return null;
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

class NotificationScheduleSnapshot {
  const NotificationScheduleSnapshot({
    this.todayCheckedIn = false,
    this.smokeFreeDuration = Duration.zero,
    this.smokeFreeStreakDays = 0,
    this.checkInStreakDays = 0,
    this.cigarettesAvoided = 0,
    this.moneySaved = 0,
    this.currencySymbol = r'$',
  });

  final bool todayCheckedIn;
  final Duration smokeFreeDuration;
  final int smokeFreeStreakDays;
  final int checkInStreakDays;
  final int cigarettesAvoided;
  final double moneySaved;
  final String currencySymbol;
}

class _NotificationCopy {
  const _NotificationCopy({required this.title, required this.body});

  final String title;
  final String body;
}
