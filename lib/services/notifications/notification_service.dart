import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/calculations/progress_calculations.dart';
import '../../models/smoking_window_data.dart';
import '../../repositories/notification_preferences_repository.dart';

class NotificationService {
  const NotificationService._();

  static const int dailyCheckInId = 1001;
  static const int milestoneReminderId = 1002;
  static const int streakProtectionId = 1003;
  static const int _dailyCheckInBaseId = 1100;
  static const int _streakProtectionBaseId = 1200;
  static const int _ritualBaseId = 1300;
  static const int _ritualIdStride = 8;
  static const int _maxRituals = 12;
  static const int _delayCheckId = 1400;
  static const int _rollingReminderDays = 7;
  static const _delayCheckKey = 'notifications.delay_check_at';

  /// Where a notification about a craving should open the app.
  static const rescueRoute = '/rescue';
  static const checkInRoute = '/check-in';
  static const milestonesRoute = '/stats/milestones';

  /// How long before a ritual its nudge arrives.
  static const ritualLeadMinutes = 10;

  /// The route a tapped notification asked for. The app listens, navigates
  /// and clears it.
  static final ValueNotifier<String?> openRoute = ValueNotifier(null);

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) =>
          _requestRoute(response.payload),
    );

    // The app may have been started by tapping a notification.
    final launch = await plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _requestRoute(launch?.notificationResponse?.payload);
    }
  }

  static void _requestRoute(String? payload) {
    if (payload != null && payload.startsWith('/')) {
      openRoute.value = payload;
    }
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }
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
    List<SmokingWindowData> rituals = const [],
    NotificationScheduleSnapshot snapshot =
        const NotificationScheduleSnapshot(),
  }) async {
    if (kIsWeb) {
      return;
    }
    // Clearing the schedule would also drop a pending "not for ten minutes"
    // check, so carry it across.
    final delayCheckAt = await _pendingDelayCheck();
    await cancelScheduledReminders();
    if (delayCheckAt != null) {
      await _scheduleDelayCheck(delayCheckAt);
    }

    if (preferences.dailyCheckInEnabled) {
      final copy = _dailyCheckInCopy(snapshot);
      await _scheduleRollingOneShots(
        baseId: _dailyCheckInBaseId,
        hour: preferences.dailyCheckInHour,
        minute: preferences.dailyCheckInMinute,
        skipToday: snapshot.todayCheckedIn,
        title: copy.title,
        body: copy.body,
        payload: checkInRoute,
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
        payload: checkInRoute,
      );
    }

    if (preferences.dangerWindowEnabled) {
      final enabled = rituals
          .where((ritual) => ritual.enabled)
          .take(_maxRituals)
          .toList();
      for (var index = 0; index < enabled.length; index++) {
        final ritual = enabled[index];
        final reminderMinutes =
            (ritual.startMinutes - ritualLeadMinutes) % (24 * 60);
        final copy = ritualCopy(ritual);
        await _scheduleRollingOneShots(
          baseId: _ritualBaseId + index * _ritualIdStride,
          hour: reminderMinutes ~/ 60,
          minute: reminderMinutes.remainder(60),
          skipToday: false,
          title: copy.title,
          body: copy.body,
          payload: rescueRoute,
          details: _ritualDetails(),
          daysOfWeek: ritual.daysOfWeek,
        );
      }
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
          notificationDetails: _milestoneDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: milestonesRoute,
        );
      }
    }
  }

  static Future<void> cancelScheduledReminders() async {
    if (kIsWeb) {
      return;
    }
    // ZeroPuff only schedules its own reminders, so clearing everything is
    // equivalent to (and much cheaper than) cancelling each id in turn.
    await plugin.cancelAll();
    final store = await SharedPreferences.getInstance();
    await store.remove(_delayCheckKey);
  }

  /// Asks again after a craving was put off. Returns false when the user will
  /// not see it because notifications are turned off.
  static Future<bool> scheduleDelayCheck({
    Duration delay = const Duration(minutes: 10),
  }) async {
    if (kIsWeb) {
      return false;
    }
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (await android?.areNotificationsEnabled() == false) {
      return false;
    }
    await _scheduleDelayCheck(DateTime.now().add(delay));
    return true;
  }

  static Future<void> _scheduleDelayCheck(DateTime at) async {
    final store = await SharedPreferences.getInstance();
    await store.setInt(_delayCheckKey, at.millisecondsSinceEpoch);
    await plugin.zonedSchedule(
      id: _delayCheckId,
      title: 'Ten minutes are up',
      body: 'Still want it? Open ZeroPuff and check in with the urge first.',
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _ritualDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: rescueRoute,
    );
  }

  static Future<DateTime?> _pendingDelayCheck() async {
    final store = await SharedPreferences.getInstance();
    final millis = store.getInt(_delayCheckKey);
    if (millis == null) {
      return null;
    }
    final at = DateTime.fromMillisecondsSinceEpoch(millis);
    return at.isAfter(DateTime.now()) ? at : null;
  }

  static Future<void> _scheduleRollingOneShots({
    required int baseId,
    required int hour,
    required int minute,
    required bool skipToday,
    required String title,
    required String body,
    required String payload,
    NotificationDetails? details,
    List<int>? daysOfWeek,
  }) async {
    final firstOffset = _firstReminderOffset(
      hour: hour,
      minute: minute,
      skipToday: skipToday,
    );
    for (var index = 0; index < _rollingReminderDays; index++) {
      final scheduledDate = _timeOnDayOffset(
        hour: hour,
        minute: minute,
        daysFromToday: firstOffset + index,
      );
      if (daysOfWeek != null &&
          !daysOfWeek.contains(_deviceWeekday(scheduledDate))) {
        continue;
      }
      await plugin.zonedSchedule(
        id: baseId + index,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details ?? _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  /// The weekday on the device's own clock (tz.local is UTC here).
  static int _deviceWeekday(tz.TZDateTime time) {
    return DateTime.fromMillisecondsSinceEpoch(
      time.millisecondsSinceEpoch,
    ).weekday;
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
    // tz.local is UTC (no timezone plugin), so build the wall-clock time with
    // Dart's device-local DateTime and convert it to an absolute instant.
    // DateTime normalizes day overflow and respects DST changes.
    final now = DateTime.now();
    final localTime = DateTime(
      now.year,
      now.month,
      now.day + daysFromToday,
      hour,
      minute,
    );
    return tz.TZDateTime.from(localTime, tz.local);
  }

  static _NotificationCopy _dailyCheckInCopy(
    NotificationScheduleSnapshot snapshot,
  ) {
    final progress = _progressLine(snapshot);
    if (snapshot.smokeFreeStreakDays >= 1) {
      return _NotificationCopy(
        title: 'Seal day ${snapshot.smokeFreeStreakDays + 1}',
        body: '$progress One tap closes today and banks it.',
      );
    }
    if (snapshot.moneySaved >= 1) {
      return _NotificationCopy(
        title: 'Seal today',
        body:
            'You have kept ${_money(snapshot)} so far. One tap closes the day.',
      );
    }
    return const _NotificationCopy(
      title: 'Seal today',
      body: 'One tap closes the day. No judgement either way.',
    );
  }

  static _NotificationCopy _streakProtectionCopy(
    NotificationScheduleSnapshot snapshot,
  ) {
    if (snapshot.smokeFreeStreakDays >= 1) {
      return const _NotificationCopy(
        title: 'Today is not sealed yet',
        body: 'One tap before bed banks it. Your run is safe either way.',
      );
    }
    return const _NotificationCopy(
      title: 'Close today gently',
      body: 'One tap seals the day, however it went.',
    );
  }

  /// What a nudge says shortly before a smoking moment.
  @visibleForTesting
  static ({String title, String body}) ritualCopy(SmokingWindowData ritual) {
    final time = SmokingWindowData.labelForMinutes(ritual.startMinutes);
    if (ritual.source == 'learned') {
      return (
        title: 'Cravings often find you around $time',
        body: 'Get ahead of this one. Six slow breaths before it arrives.',
      );
    }
    if (ritual.isPrimary) {
      return (
        title: 'Your usual smoking time starts soon',
        body:
            'Around $time is when autopilot kicks in. Take six breaths before it does.',
      );
    }
    return (
      title: '${ritual.label} is coming up',
      body:
          'That used to mean a cigarette. Get ahead of it: six slow breaths first.',
    );
  }

  static String _progressLine(NotificationScheduleSnapshot snapshot) {
    if (snapshot.moneySaved >= 1) {
      return '${_money(snapshot)} won back.';
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
      channelDescription: 'Reminders to seal the day.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  static NotificationDetails _ritualDetails() {
    const android = AndroidNotificationDetails(
      'zeropuff_rituals',
      'Craving moments',
      channelDescription:
          'A heads-up shortly before the times you used to smoke.',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          'breathe',
          'Breathe now',
          showsUserInterface: true,
        ),
      ],
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  static NotificationDetails _milestoneDetails() {
    const android = AndroidNotificationDetails(
      'zeropuff_milestones',
      'Milestones',
      channelDescription: 'When you reach a smoke-free milestone.',
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
