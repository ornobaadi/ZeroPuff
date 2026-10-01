import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/calculations/progress_calculations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../../celebrations/milestone_celebration_controller.dart';
import '../../celebrations/widgets/celebration_dialog.dart';
import '../providers/home_dashboard_provider.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/smoke_free_hero_card.dart';
import '../../../core/utils/number_formatting.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.enableNotificationRefresh = true});

  final bool enableNotificationRefresh;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
          data: (data) => _HomeContent(data: data, onOpen: _openRoute),
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

  Future<void> _rescheduleNotifications([HomeDashboardData? data]) async {
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .load();
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
    final dashboard = data ?? ref.read(homeDashboardProvider).value;
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile?.quitDate,
      smokingWindow: profile?.usualSmokingWindow,
      snapshot: dashboard == null
          ? const NotificationScheduleSnapshot()
          : NotificationScheduleSnapshot(
              todayCheckedIn: dashboard.todayCheckIn != null,
              smokeFreeDuration: dashboard.smokeFreeDuration,
              smokeFreeStreakDays: dashboard.smokeFreeStreakDays,
              checkInStreakDays: dashboard.checkInStreakDays,
              cigarettesAvoided: dashboard.cigarettesAvoided,
              moneySaved: dashboard.moneySaved,
              currencySymbol: dashboard.currencySymbol,
            ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data, required this.onOpen});

  final HomeDashboardData data;
  final void Function(String route, {bool stronger}) onOpen;

  @override
  Widget build(BuildContext context) {
    final streakDays = data.smokeFreeStreakDays;

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
