import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calculations/craving_analysis_calculations.dart';
import '../../models/craving_rescue_data.dart';
import '../../models/smoking_window_data.dart';
import '../../repositories/craving_repository.dart';
import '../../repositories/notification_preferences_repository.dart';
import '../../repositories/onboarding_repository.dart';
import '../../repositories/smoking_window_repository.dart';
import '../../services/notifications/notification_service.dart';
import '../home/providers/home_dashboard_provider.dart';

/// Cravings needed before the app trusts a pattern enough to nudge on it.
const _learnedNudgeMinimum = 14;

/// Rebuilds every scheduled reminder from the current state of the app.
///
/// Call it whenever something a reminder depends on changes: a check-in, a
/// rescue, a setting, a ritual. Failures are swallowed because reminders are
/// rebuilt again the next time Home loads.
Future<void> refreshReminders(
  WidgetRef ref, {
  NotificationPreferences? preferences,
  HomeDashboardData? dashboard,
  bool? todayCheckedIn,
}) async {
  try {
    final saved =
        preferences ??
        await ref.read(notificationPreferencesRepositoryProvider).load();
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
    final data = dashboard ?? ref.read(homeDashboardProvider).value;
    final rituals = await ref
        .read(smokingWindowRepositoryProvider)
        .loadRituals();
    final cravings = await ref
        .read(cravingRepositoryProvider)
        .recent(limit: 90);

    final now = DateTime.now();
    final quitDate = profile?.quitDate;
    await NotificationService.reschedule(
      preferences: saved,
      quitDate: quitDate,
      rituals: nudgeMoments(
        rituals: rituals,
        usualWindow: profile?.usualSmokingWindow,
        cravings: cravings,
        now: now,
      ),
      snapshot: data == null
          ? NotificationScheduleSnapshot(
              todayCheckedIn: todayCheckedIn ?? false,
              smokeFreeDuration: quitDate == null || now.isBefore(quitDate)
                  ? Duration.zero
                  : now.difference(quitDate),
              currencySymbol: profile?.currencySymbol ?? r'$',
            )
          : NotificationScheduleSnapshot(
              todayCheckedIn: todayCheckedIn ?? data.todayCheckIn != null,
              smokeFreeDuration: data.smokeFreeDuration,
              smokeFreeStreakDays: data.smokeFreeStreakDays,
              checkInStreakDays: data.checkInStreakDays,
              cigarettesAvoided: data.cigarettesAvoided,
              moneySaved: data.moneySaved,
              currencySymbol: data.currencySymbol,
            ),
    );
  } on Object {
    // Reminders are a nicety; nothing the user is doing depends on them.
  }
}

/// The moments worth a heads-up: the user's rituals, or their single usual
/// window when they have none, plus the time of day cravings actually cluster
/// once there is enough history and no ritual already covers it.
List<SmokingWindowData> nudgeMoments({
  required List<SmokingWindowData> rituals,
  required SmokingWindowData? usualWindow,
  required List<CravingRescueData> cravings,
  required DateTime now,
}) {
  final moments = <SmokingWindowData>[
    if (rituals.isNotEmpty) ...rituals else ?usualWindow,
  ];

  if (cravings.length >= _learnedNudgeMinimum) {
    final peak = CravingAnalysisCalculations.analyze(
      cravings: cravings,
      smokingLogs: const [],
      now: now,
    ).peakWindow;
    if (peak != null) {
      final peakMinutes = peak.startHour * 60;
      final covered = moments.any((moment) {
        final apart = (moment.startMinutes - peakMinutes).abs();
        return (apart > 12 * 60 ? 24 * 60 - apart : apart) <= 90;
      });
      if (!covered) {
        moments.add(
          SmokingWindowData(
            windowId: 'learned',
            label: 'learned',
            startMinutes: peakMinutes,
            endMinutes: (peakMinutes + 120).clamp(0, 24 * 60),
            isPrimary: false,
            source: 'learned',
          ),
        );
      }
    }
  }
  return moments;
}
