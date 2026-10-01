import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/friendly_error.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/number_stepper.dart';
import '../../../core/widgets/state_view.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';

/// How the day felt with respect to smoking, from hardest (1) to clearest (5).
const _levels = [
  _DayLevel(
    1,
    'Hard day',
    'Strong urges',
    'Cravings felt loud, patience was low, or the day asked a lot from you.',
    Symbols.thunderstorm_rounded,
  ),
  _DayLevel(
    2,
    'Unsettled',
    'On edge',
    'You felt pulled toward smoking, bored, irritated, or restless.',
    Symbols.waves_rounded,
  ),
  _DayLevel(
    3,
    'Managing',
    'Still aware',
    'Some pressure showed up, but you could still pause and notice it.',
    Symbols.balance_rounded,
  ),
  _DayLevel(
    4,
    'Steady',
    'Mostly calm',
    'Cravings passed more easily, or you felt more in charge today.',
    Symbols.spa_rounded,
  ),
  _DayLevel(
    5,
    'Clear',
    'Feeling light',
    'You felt lighter, confident, or mostly free from smoking thoughts.',
    Symbols.wb_sunny_rounded,
  ),
];

class DailyCheckInScreen extends ConsumerStatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  ConsumerState<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends ConsumerState<DailyCheckInScreen> {
  int _level = 3;
  bool _smokeFreeToday = true;
  int _cigarettesSmoked = 0;
  bool _loadingExisting = true;
  bool _saving = false;
  Object? _loadError;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() {
      _loadingExisting = true;
      _loadError = null;
    });
    try {
      final existing = await ref
          .read(dailyCheckInRepositoryProvider)
          .getToday();
      if (!mounted) {
        return;
      }
      if (existing != null) {
        setState(() {
          _level = existing.mood.clamp(1, 5);
          _smokeFreeToday = existing.smokeFreeToday;
          _cigarettesSmoked = existing.cigarettesSmoked;
          _noteController.text = existing.note ?? '';
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _loadError = error);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingExisting = false);
      }
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    _mediumHaptic();
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(dailyCheckInRepositoryProvider)
          .saveToday(
            mood: _level,
            smokeFreeToday: _smokeFreeToday,
            cigarettesSmoked: _smokeFreeToday ? 0 : _cigarettesSmoked,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      ref.invalidate(todayCheckInProvider);
      ref.invalidate(recentCheckInsProvider);
      await _rescheduleNotificationsAfterCheckIn();
      if (mounted) {
        context.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Check-in saved. Thank you.')),
        );
      }
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(error))));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget body;
    if (_loadingExisting) {
      body = const StateView.loading(label: 'Loading check-in');
    } else if (_loadError != null) {
      body = StateView.error(error: _loadError!, onRetry: _loadExisting);
    } else {
      body = ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'How did today go?',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This is a private honesty check. No streak shaming.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _DayScale(
                  level: _currentLevel,
                  onChanged: (value) {
                    if (value != _level) {
                      _selectionHaptic();
                      setState(() => _level = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  style: AppCardStyle.outlined,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Smoke-free today?',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      _smokeFreeToday
                          ? 'Nice. We will mark today complete.'
                          : 'Still useful. Honesty keeps the pattern clear.',
                    ),
                    value: _smokeFreeToday,
                    onChanged: (value) {
                      _selectionHaptic();
                      setState(() {
                        _smokeFreeToday = value;
                        if (value) {
                          _cigarettesSmoked = 0;
                        } else if (_cigarettesSmoked == 0) {
                          _cigarettesSmoked = 1;
                        }
                      });
                    },
                  ),
                ),
                if (!_smokeFreeToday) ...[
                  const SizedBox(height: AppSpacing.md),
                  NumberStepper(
                    label: 'Cigarettes today',
                    value: _cigarettesSmoked,
                    min: 1,
                    max: 80,
                    onChanged: (value) {
                      _selectionHaptic();
                      setState(() => _cigarettesSmoked = value);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _noteController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Optional note',
                    hintText: 'What helped or got in the way?',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily check-in')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (!_loadingExisting && _loadError == null)
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              semanticsLabel: 'Saving',
                            ),
                          )
                        : const Icon(Symbols.check_rounded),
                    label: Text(_saving ? 'Saving' : 'Save check-in'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() {
    HapticService.selection(enabled: _hapticsEnabled);
  }

  void _mediumHaptic() {
    HapticService.medium(enabled: _hapticsEnabled);
  }

  _DayLevel get _currentLevel {
    return _levels.firstWhere(
      (level) => level.value == _level,
      orElse: () => _levels[2],
    );
  }

  Future<void> _rescheduleNotificationsAfterCheckIn() async {
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .load();
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
    final dashboard = ref.read(homeDashboardProvider).value;
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile?.quitDate,
      smokingWindow: profile?.usualSmokingWindow,
      snapshot: dashboard == null
          ? const NotificationScheduleSnapshot(todayCheckedIn: true)
          : NotificationScheduleSnapshot(
              todayCheckedIn: true,
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

class _DayScale extends StatelessWidget {
  const _DayScale({required this.level, required this.onChanged});

  final _DayLevel level;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('How it felt', style: theme.textTheme.titleMedium),
            ),
            IconButton(
              tooltip: 'What each level means',
              onPressed: () => _showGuide(context),
              icon: const Icon(Symbols.info_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          style: AppCardStyle.outlined,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: AppMotion.of(context, AppMotion.short),
                    child: DecoratedBox(
                      key: ValueKey(level.value),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.componentGap),
                        child: Icon(
                          level.icon,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level.label, style: theme.textTheme.titleLarge),
                        Text(
                          level.subtitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${level.value}/5',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                level.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Slider(
                value: level.value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '${level.value}/5 ${level.label}',
                semanticFormatterCallback: (value) {
                  final rounded = value.round().clamp(1, 5);
                  final selected = _levels[rounded - 1];
                  return 'Level $rounded of 5, ${selected.label}. ${selected.description}';
                },
                onChanged: (value) => onChanged(value.round().clamp(1, 5)),
              ),
              ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final option in _levels)
                      Expanded(
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              0,
              AppSpacing.pagePadding,
              AppSpacing.pagePadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How it felt', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pick the level that best matches your smoking pressure today.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final option in _levels) ...[
                  _GuideRow(option: option),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.option});

  final _DayLevel option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                '${option.value}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(option.label, style: theme.textTheme.titleSmall),
              Text(
                option.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayLevel {
  const _DayLevel(
    this.value,
    this.label,
    this.subtitle,
    this.description,
    this.icon,
  );

  final int value;
  final String label;
  final String subtitle;
  final String description;
  final IconData icon;
}
