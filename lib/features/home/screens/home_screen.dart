import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/day_history.dart';
import '../../../core/calculations/today_card_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/state_view.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_loop_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/widget/home_widget_service.dart';
import '../../celebrations/milestone_celebration_controller.dart';
import '../../celebrations/widgets/celebration_dialog.dart';
import '../../logging/widgets/slip_form.dart';
import '../../notifications/reminder_refresh.dart';
import '../../share/share_card.dart';
import '../providers/home_dashboard_provider.dart';
import '../providers/today_card_provider.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/jar_card.dart';
import '../widgets/smoke_free_hero_card.dart';
import '../widgets/today_card.dart';
import '../widgets/week_chain.dart';
import '../../../core/utils/number_formatting.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.enableNotificationRefresh = true});

  final bool enableNotificationRefresh;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// The opening heartbeat plays once per app launch, not per visit to Home.
  static bool _heartbeatPlayed = false;

  String? _shownCelebrationKey;
  String? _checkedGoalKey;
  String? _lastNotificationRefreshKey;

  @override
  void initState() {
    super.initState();
    ref.listenManual(milestoneCelebrationProvider, (previous, next) {
      final event = next.value;
      if (event == null || event.key == _shownCelebrationKey) {
        return;
      }
      _shownCelebrationKey = event.key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCelebrationDialog(event);
          if (event.kind == CelebrationKind.milestone) {
            _rescheduleNotifications();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(homeDashboardProvider);
    ref.watch(milestoneCelebrationProvider);
    if (widget.enableNotificationRefresh) {
      dashboard.whenData(_queueNotificationRefresh);
      dashboard.whenData(_playHeartbeat);
      final goal = ref.watch(savingsGoalProvider).value;
      final saved = dashboard.value?.moneySaved;
      if (goal != null && saved != null && goal.reachedWith(saved)) {
        _celebrateGoal(goal, dashboard.value!.currencySymbol);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroPuff'),
        actions: [
          dashboard.maybeWhen(
            data: (data) => StreakChip(
              streak: data.smokeFreeStreakDays,
              onTap: () => _openRoute(AppRoutes.streakDetails),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: dashboard.when(
          data: (data) => _HomeContent(
            data: data,
            today: ref.watch(todayCardProvider),
            history: ref.watch(dayHistoryProvider),
            onOpen: _openRoute,
            onTodayAction: _onTodayAction,
            onSlip: () => showSlipSheet(context),
          ),
          loading: () => const StateView.loading(label: 'Loading your day'),
          error: (error, _) => StateView.error(
            error: error,
            onRetry: () {
              ref.invalidate(homeBaselineProvider);
              ref.invalidate(latestSmokeAtProvider);
              ref.invalidate(todayCheckInProvider);
              ref.invalidate(recentCheckInsProvider);
              ref.invalidate(recentSmokingLogsProvider);
              ref.invalidate(recentCravingsProvider);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCelebrationDialog(CelebrationEvent event) async {
    // Longer milestones land harder.
    final weight = event.kind != CelebrationKind.milestone
        ? MilestoneWeight.small
        : event.duration >= const Duration(days: 7)
        ? MilestoneWeight.large
        : MilestoneWeight.medium;
    HapticService.milestone(
      enabled: ref.read(hapticsEnabledControllerProvider),
      weight: weight,
    );
    final data = ref.read(homeDashboardProvider).value;
    await showDialog<void>(
      context: context,
      builder: (context) => CelebrationDialog(
        event: event,
        onShare: () => showShareCard(context, _shareCardFor(event, data)),
      ),
    );
  }

  ShareCardData _shareCardFor(CelebrationEvent event, HomeDashboardData? data) {
    final isMilestone = event.kind == CelebrationKind.milestone;
    if (event.key.startsWith('goal:')) {
      return ShareCardData(
        headline: event.title.replaceFirst(' is yours', ''),
        caption: 'paid for by not smoking',
      );
    }
    return ShareCardData(
      headline: isMilestone
          ? event.title.replaceFirst(' smoke-free', '')
          : event.title,
      caption: isMilestone ? 'smoke-free' : 'unlocked',
      lines: [
        if (data != null && data.cigarettesAvoided > 0)
          '${formatCount(data.cigarettesAvoided)} cigarettes not smoked',
        if (data != null && data.moneySaved >= 1)
          '${formatMoney(data.currencySymbol, data.moneySaved)} kept',
      ],
    );
  }

  void _openRoute(String route, {bool stronger = false}) {
    final enabled = ref.read(hapticsEnabledControllerProvider);
    if (stronger) {
      HapticService.light(enabled: enabled);
    } else {
      HapticService.selection(enabled: enabled);
    }
    context.push(route);
  }

  /// A double beat on opening the app that gets firmer as the streak grows,
  /// so progress can be felt before it is read.
  void _playHeartbeat(HomeDashboardData data) {
    if (_heartbeatPlayed || data.smokeFreeStreakDays < 1) {
      return;
    }
    _heartbeatPlayed = true;
    HapticService.heartbeat(
      enabled: ref.read(hapticsEnabledControllerProvider),
      strength: data.smokeFreeStreakDays / 30,
    );
  }

  /// The savings goal has been reached: celebrate it, once.
  Future<void> _celebrateGoal(SavingsGoal goal, String currencySymbol) async {
    final key = 'goal:${goal.name}:${goal.target}';
    if (_shownCelebrationKey == key || _checkedGoalKey == key) {
      return;
    }
    _checkedGoalKey = key;
    final repository = ref.read(dailyLoopRepositoryProvider);
    if (await repository.hasCelebratedGoal(goal)) {
      return;
    }
    await repository.markGoalCelebrated(goal);
    if (!mounted) {
      return;
    }
    _shownCelebrationKey = key;
    await _showCelebrationDialog(
      CelebrationEvent(
        kind: CelebrationKind.timeAchievement,
        key: key,
        title: '${goal.name} is yours',
        body:
            'You kept ${formatMoney(currencySymbol, goal.target)} by not smoking. Go and get it.',
        duration: Duration.zero,
        icon: Symbols.savings_rounded,
      ),
    );
  }

  Future<void> _onTodayAction(TodayCard card) async {
    final enabled = ref.read(hapticsEnabledControllerProvider);
    switch (card.kind) {
      case TodayCardKind.ritualSoon:
        _openRoute(AppRoutes.rescue, stronger: true);
      case TodayCardKind.sealDay:
        _openRoute(AppRoutes.checkIn);
      case TodayCardKind.pledge:
        HapticService.success(enabled: enabled);
        await ref.read(dailyLoopRepositoryProvider).pledge(DateTime.now());
        ref.invalidate(pledgedTodayProvider);
      case TodayCardKind.goal:
        _openRoute(AppRoutes.savingsDetails);
      case TodayCardKind.recap:
      case TodayCardKind.insight:
      case TodayCardKind.steady:
        break;
    }
  }

  void _queueNotificationRefresh(HomeDashboardData data) {
    final now = DateTime.now();
    final key =
        '${now.year}-${now.month}-${now.day}:'
        '${data.todayCheckIn?.checkInId ?? 'open'}:'
        '${data.smokeFreeStreakDays}:'
        '${data.cigarettesAvoided}:'
        '${data.moneySaved.floor()}';
    if (_lastNotificationRefreshKey == key) {
      return;
    }
    _lastNotificationRefreshKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rescheduleNotifications(data);
        HomeWidgetService.update(
          smokeFreeSince: data.smokeFreeSince,
          dailySpend: data.packSize <= 0
              ? 0
              : data.cigarettesPerDay / data.packSize * data.packPrice,
          moneyKept: data.moneySaved,
          currencySymbol: data.currencySymbol,
        );
      }
    });
  }

  Future<void> _rescheduleNotifications([HomeDashboardData? data]) {
    return refreshReminders(ref, dashboard: data);
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.today,
    required this.history,
    required this.onOpen,
    required this.onTodayAction,
    required this.onSlip,
  });

  final HomeDashboardData data;
  final TodayCard? today;
  final DayHistory? history;
  final void Function(String route, {bool stronger}) onOpen;
  final ValueChanged<TodayCard> onTodayAction;
  final VoidCallback onSlip;

  @override
  Widget build(BuildContext context) {
    final today = this.today;
    final history = this.history;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        // Clears the floating navigation bar the page scrolls under.
        AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmokeFreeHeroCard(
                data: data,
                onTap: () => onOpen(AppRoutes.smokeFreeDetails),
              ),
              const SizedBox(height: AppSpacing.md),
              CravingButton(
                onPressed: () => onOpen(AppRoutes.rescue, stronger: true),
              ),
              // Deliberately quiet: logging a slip should be easy to find
              // without competing with the rescue.
              Center(
                child: TextButton.icon(
                  onPressed: onSlip,
                  icon: const Icon(Symbols.edit_note_rounded),
                  label: const Text('I slipped'),
                ),
              ),
              if (today != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TodayCardView(
                  card: today,
                  onAction: () => onTodayAction(today),
                ),
              ],
              if (history != null) ...[
                const SizedBox(height: AppSpacing.md),
                WeekChain(
                  history: history,
                  onTap: () => onOpen(AppRoutes.streakDetails),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              JarCard(
                data: data,
                onTap: () => onOpen(AppRoutes.savingsDetails),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
