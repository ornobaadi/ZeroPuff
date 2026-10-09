import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/calculations/today_card_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_loop_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../celebrations/milestone_celebration_controller.dart';
import '../../celebrations/widgets/celebration_dialog.dart';
import '../../notifications/reminder_refresh.dart';
import '../providers/home_dashboard_provider.dart';
import '../providers/today_card_provider.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/smoke_free_hero_card.dart';
import '../widgets/today_card.dart';
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
          IconButton(
            tooltip: 'Log a cigarette',
            onPressed: () => _openRoute(AppRoutes.logging, stronger: true),
            icon: const Icon(Symbols.edit_note_rounded),
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
            onOpen: _openRoute,
            onTodayAction: _onTodayAction,
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
    HapticService.success(enabled: ref.read(hapticsEnabledControllerProvider));
    await showDialog<void>(
      context: context,
      builder: (context) => CelebrationDialog(event: event),
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

  Future<void> _onTodayAction(TodayCard card) async {
    final enabled = ref.read(hapticsEnabledControllerProvider);
    switch (card.kind) {
      case TodayCardKind.ritualSoon:
        _openRoute(AppRoutes.rescue, stronger: true);
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
    required this.onOpen,
    required this.onTodayAction,
  });

  final HomeDashboardData data;
  final TodayCard? today;
  final void Function(String route, {bool stronger}) onOpen;
  final ValueChanged<TodayCard> onTodayAction;

  @override
  Widget build(BuildContext context) {
    final streakDays = data.smokeFreeStreakDays;
    final today = this.today;

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
              if (today != null) ...[
                const SizedBox(height: AppSpacing.md),
                TodayCardView(
                  card: today,
                  onAction: () => onTodayAction(today),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              CheckInCard(
                checkedIn: data.todayCheckIn != null,
                smokeFreeToday: data.todayCheckIn?.smokeFreeToday,
                onTap: () => onOpen(AppRoutes.checkIn),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(title: 'Your progress'),
              _StatsGrid(
                cards: [
                  StatCard(
                    label: 'Not smoked',
                    value: '${data.cigarettesAvoided}',
                    suffix: 'cigarettes',
                    icon: Symbols.smoke_free_rounded,
                    onTap: () => onOpen(AppRoutes.avoidedDetails),
                  ),
                  StatCard(
                    label: 'Money won back',
                    value:
                        formatMoney(data.currencySymbol, data.moneySaved),
                    suffix: 'estimated',
                    icon: Symbols.savings_rounded,
                    tone: StatTone.money,
                    onTap: () => onOpen(AppRoutes.savingsDetails),
                  ),
                  StatCard(
                    label: 'Time smoke-free',
                    value: ProgressCalculations.durationLabel(
                      data.smokeFreeDuration,
                    ),
                    suffix: 'so far',
                    icon: Symbols.timer_rounded,
                    onTap: () => onOpen(AppRoutes.milestoneDetails),
                  ),
                  StatCard(
                    label: 'Smoke-free streak',
                    value: '$streakDays',
                    suffix: streakDays == 1 ? 'day' : 'days',
                    icon: Symbols.local_fire_department_rounded,
                    tone: StatTone.streak,
                    onTap: () => onOpen(AppRoutes.streakDetails),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              QuickLogCard(
                onTap: () => onOpen(AppRoutes.logging, stronger: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Two columns of equal-height cards.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < cards.length; index += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[index]),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: index + 1 < cards.length
                    ? cards[index + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      if (index + 2 < cards.length) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
    }
    return Column(children: rows);
  }
}
