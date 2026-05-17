import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/craving_repository.dart';

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
          final leave = await _confirmLeave();
          if (leave && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Two-minute rescue')),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
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
    }
    await ref
        .read(appEventRepositoryProvider)
        .track(AppEvent(eventName: 'craving_outcome_$outcome'));

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_outcomeMessage(outcome))));
    }
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
        Text(
          'Give me two minutes before you decide.',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Intensity: $intensity', style: theme.textTheme.titleMedium),
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
            return FilterChip(
              label: Text(trigger),
              selected: triggers.contains(trigger),
              onSelected: (_) => onTriggerToggled(trigger),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),
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
          Text('$minutes:$seconds', style: theme.textTheme.displayLarge),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: AppSpacing.xl),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Text(action, style: theme.textTheme.headlineSmall),
            ),
          ),
          const Spacer(),
          Text(
            'No decision right now. Just finish this minute.',
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
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () => onOutcome('resisted'),
          child: const Text('I resisted'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: () => onOutcome('still_craving'),
          child: const Text('Still craving'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.relapse),
          onPressed: () => onOutcome('smoked'),
          child: const Text('I smoked'),
        ),
      ],
    );
  }
}
