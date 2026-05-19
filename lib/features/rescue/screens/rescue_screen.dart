import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/craving_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/notifications/notification_service.dart';

const _rescueTriggers = [
  'stress',
  'bored',
  'social',
  'after food',
  'coffee',
  'other',
];

const _microActions = [
  'Drink a full glass of water.',
  'Walk to a different room.',
  'Take 3 slow breaths. In 4, hold 4, out 6.',
  'Read your quit reason. Let it be enough for this minute.',
];

enum _RescueStage { setup, active, outcome }

class RescueScreen extends ConsumerStatefulWidget {
  const RescueScreen({super.key});

  @override
  ConsumerState<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends ConsumerState<RescueScreen> {
  static const _totalSeconds = 120;

  int _intensity = 5;
  int _remainingSeconds = _totalSeconds;
  final Set<String> _triggers = {'stress'};
  _RescueStage _stage = _RescueStage.setup;
  Timer? _timer;
  String? _sessionId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage != _RescueStage.active,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _stage == _RescueStage.active) {
          final navigator = Navigator.of(context);
          final leave = await _confirmLeave();
          if (leave && mounted) {
            await _restoreReminders();
            if (mounted) {
              navigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Two-minute rescue')),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: switch (_stage) {
              _RescueStage.setup => _SetupView(
                intensity: _intensity,
                triggers: _triggers,
                onIntensityChanged: (value) {
                  setState(() => _intensity = value.round());
                },
                onTriggerToggled: _toggleTrigger,
                onStart: _startRescue,
              ),
              _RescueStage.active => _ActiveView(
                remainingSeconds: _remainingSeconds,
                action: _microActions[_actionIndex],
              ),
              _RescueStage.outcome => _OutcomeView(onOutcome: _completeRescue),
            },
          ),
        ),
      ),
    );
  }

  int get _actionIndex {
    final elapsed = _totalSeconds - _remainingSeconds;
    return (elapsed ~/ 30).clamp(0, _microActions.length - 1);
  }

  void _toggleTrigger(String trigger) {
    setState(() {
      if (_triggers.contains(trigger) && _triggers.length > 1) {
        _triggers.remove(trigger);
      } else {
        _triggers.add(trigger);
      }
    });
  }

  Future<void> _startRescue() async {
    final repository = ref.read(cravingRepositoryProvider);
    final eventRepository = ref.read(appEventRepositoryProvider);
    await NotificationService.cancelScheduledReminders();
    final sessionId = await repository.startRescue(
      intensity: _intensity,
      triggers: _triggers.toList(),
    );
    await eventRepository.track(
      AppEvent(
        eventName: 'craving_rescue_started',
        properties: {'intensity': _intensity, 'triggers': _triggers.toList()},
      ),
    );

    setState(() {
      _sessionId = sessionId;
      _remainingSeconds = _totalSeconds;
      _stage = _RescueStage.active;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _stage = _RescueStage.outcome;
        });
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  Future<void> _completeRescue(String outcome) async {
    final sessionId = _sessionId;
    if (sessionId != null) {
      await ref
          .read(cravingRepositoryProvider)
          .completeRescue(sessionId: sessionId, outcome: outcome);
      ref.invalidate(recentCravingsProvider);
    }
    await ref
        .read(appEventRepositoryProvider)
        .track(AppEvent(eventName: 'craving_outcome_$outcome'));
    await _restoreReminders();

    if (mounted) {
      if (outcome == 'smoked') {
        Navigator.of(context).pop();
        GoRouter.of(context).push('/log-smoke');
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_outcomeMessage(outcome))));
    }
  }

  Future<void> _restoreReminders() async {
    final preferences = await ref
        .read(notificationPreferencesRepositoryProvider)
        .load();
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
    await NotificationService.reschedule(
      preferences: preferences,
      quitDate: profile?.quitDate,
    );
  }

  Future<bool> _confirmLeave() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave rescue?'),
            content: const Text(
              'You are in the two-minute window. Stay if you can.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _outcomeMessage(String outcome) {
    return switch (outcome) {
      'resisted' => 'Logged. You got through this one.',
      'smoked' => "Logged. Let's keep going.",
      _ => 'Logged. You can restart anytime.',
    };
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView({
    required this.intensity,
    required this.triggers,
    required this.onIntensityChanged,
    required this.onTriggerToggled,
    required this.onStart,
  });

  final int intensity;
  final Set<String> triggers;
  final ValueChanged<double> onIntensityChanged;
  final ValueChanged<String> onTriggerToggled;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const ValueKey('rescue-setup'),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.air_rounded, color: AppColors.primary, size: 32),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Give me two minutes before you decide.',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No pressure to be perfect. Just create a small gap.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Row(
          children: [
            Expanded(
              child: Text('Intensity', style: theme.textTheme.titleMedium),
            ),
            Text('$intensity/10', style: theme.textTheme.headlineSmall),
          ],
        ),
        Slider(
          value: intensity.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: intensity.toString(),
          onChanged: onIntensityChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Trigger', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _rescueTriggers.map((trigger) {
            final selected = triggers.contains(trigger);
            return FilterChip(
              avatar: selected
                  ? const Icon(Icons.check_rounded, size: 16)
                  : null,
              label: Text(trigger),
              selected: selected,
              onSelected: (_) => onTriggerToggled(trigger),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.timer_outlined),
          label: const Text('Start two minutes'),
        ),
      ],
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.remainingSeconds, required this.action});

  final int remainingSeconds;
  final String action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds.remainder(60).toString().padLeft(2, '0');
    final progress = 1 - (remainingSeconds / _RescueScreenState._totalSeconds);

    return Padding(
      key: const ValueKey('rescue-active'),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stay with this minute', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$minutes:$seconds',
            style: AppTypography.liveCounter.copyWith(
              fontSize: 64,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(minHeight: 10, value: progress),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.self_improvement_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(action, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'No decision right now. Just finish this window.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeView extends StatelessWidget {
  const _OutcomeView({required this.onOutcome});

  final ValueChanged<String> onOutcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const ValueKey('rescue-outcome'),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Text('What happened?', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Text(
          'No shame. Honest data is how the app gets useful.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _OutcomeButton(
          icon: Icons.check_circle_rounded,
          title: 'I resisted',
          subtitle: 'Save the win and return home.',
          color: AppColors.primary,
          onTap: () => onOutcome('resisted'),
        ),
        const SizedBox(height: AppSpacing.md),
        _OutcomeButton(
          icon: Icons.refresh_rounded,
          title: 'Still craving',
          subtitle: 'Log it, then start another rescue anytime.',
          color: AppColors.accentCraving,
          onTap: () => onOutcome('still_craving'),
        ),
        const SizedBox(height: AppSpacing.md),
        _OutcomeButton(
          icon: Icons.edit_note_rounded,
          title: 'I smoked',
          subtitle: 'Log it privately. You did not lose everything.',
          color: AppColors.relapse,
          onTap: () => onOutcome('smoked'),
        ),
      ],
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
