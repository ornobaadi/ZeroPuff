import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/daily_checkin_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';

const _moods = [
  _MoodOption(
    1,
    'Hard day',
    'Strong urges',
    'Cravings felt loud, patience was low, or the day asked a lot from you.',
    Icons.thunderstorm_rounded,
  ),
  _MoodOption(
    2,
    'Unsettled',
    'On edge',
    'You felt pulled toward smoking, bored, irritated, or restless.',
    Icons.waves_rounded,
  ),
  _MoodOption(
    3,
    'Managing',
    'Still aware',
    'Some pressure showed up, but you could still pause and notice it.',
    Icons.balance_rounded,
  ),
  _MoodOption(
    4,
    'Steady',
    'Mostly calm',
    'Cravings passed more easily, or you felt more in charge today.',
    Icons.spa_rounded,
  ),
  _MoodOption(
    5,
    'Clear',
    'Breathing easier',
    'You felt lighter, confident, or mostly free from smoking thoughts.',
    Icons.wb_sunny_rounded,
  ),
];

class DailyCheckInScreen extends ConsumerStatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  ConsumerState<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends ConsumerState<DailyCheckInScreen> {
  int _mood = 3;
  bool _smokeFreeToday = true;
  int _cigarettesSmoked = 0;
  bool _loadingExisting = true;
  bool _saving = false;
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
    final existing = await ref.read(dailyCheckInRepositoryProvider).getToday();
    if (!mounted) {
      return;
    }
    if (existing != null) {
      setState(() {
        _mood = existing.mood;
        _smokeFreeToday = existing.smokeFreeToday;
        _cigarettesSmoked = existing.cigarettesSmoked;
        _noteController.text = existing.note ?? '';
      });
    }
    setState(() => _loadingExisting = false);
  }

  Future<void> _save() async {
    _mediumHaptic();
    setState(() => _saving = true);
    try {
      await ref
          .read(dailyCheckInRepositoryProvider)
          .saveToday(
            mood: _mood,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in saved. Thank you.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily check-in')),
      body: SafeArea(
        child: _loadingExisting
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  Text(
                    'How did today go?',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This is a private honesty check. No streak shaming.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _MoodScale(
                    mood: _currentMood,
                    onChanged: (value) {
                      if (value != _mood) {
                        _selectionHaptic();
                        setState(() => _mood = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SmokeFreeSwitch(
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
                  if (!_smokeFreeToday) ...[
                    const SizedBox(height: AppSpacing.md),
                    _CountStepper(
                      value: _cigarettesSmoked,
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
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Optional note',
                      hintText: 'What helped or got in the way?',
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: FilledButton.icon(
            onPressed: _saving || _loadingExisting ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Saving' : 'Save check-in'),
          ),
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

  _MoodOption get _currentMood {
    return _moods.firstWhere(
      (mood) => mood.value == _mood,
      orElse: () => _moods[2],
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

class _MoodScale extends StatelessWidget {
  const _MoodScale({required this.mood, required this.onChanged});

  final _MoodOption mood;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.surfaceCardDark
        : AppColors.surfaceElevated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Mood', style: theme.textTheme.titleMedium)),
            Tooltip(
              message: 'What each mood level means',
              child: IconButton(
                tooltip: 'Mood guide',
                onPressed: () => _showMoodGuide(context),
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(mood.icon, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.label,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mood.subtitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${mood.value}/5',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                mood.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Slider(
                value: mood.value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '${mood.value}/5 ${mood.label}',
                semanticFormatterCallback: (value) {
                  final rounded = value.round().clamp(1, 5);
                  final selected = _moods[rounded - 1];
                  return 'Mood level $rounded of 5, ${selected.label}. ${selected.description}';
                },
                onChanged: (value) => onChanged(value.round().clamp(1, 5)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MoodScaleTick(value: '1', label: 'Hard'),
                    _MoodScaleTick(value: '2', label: 'Uneasy'),
                    _MoodScaleTick(value: '3', label: 'Managing'),
                    _MoodScaleTick(value: '4', label: 'Steady'),
                    _MoodScaleTick(value: '5', label: 'Clear'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMoodGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
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
                Text('Mood scale', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pick the level that best matches your smoking pressure today.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final option in _moods) ...[
                  _MoodGuideRow(option: option),
                  if (option.value != _moods.last.value)
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

class _MoodScaleTick extends StatelessWidget {
  const _MoodScaleTick({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _MoodGuideRow extends StatelessWidget {
  const _MoodGuideRow({required this.option});

  final _MoodOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${option.value}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.label, style: theme.textTheme.titleSmall),
                Text(
                  option.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmokeFreeSwitch extends StatelessWidget {
  const _SmokeFreeSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smoke-free today?', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value
                      ? 'Nice. We will mark today complete.'
                      : 'Still useful. Honesty keeps the pattern clear.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _CountStepper extends StatelessWidget {
  const _CountStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.relapse.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.relapse.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Cigarettes today', style: theme.textTheme.titleMedium),
          ),
          IconButton.filledTonal(
            onPressed: value <= 1 ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(
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
