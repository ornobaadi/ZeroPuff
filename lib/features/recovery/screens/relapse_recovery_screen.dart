import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/selectable_tile.dart';
import '../../../core/widgets/state_view.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/smoking_log_repository.dart';

/// Shown right after a cigarette is logged: reassurance, the pattern, and one
/// small reset action. Non-judgemental by design.
class RelapseRecoveryScreen extends ConsumerStatefulWidget {
  const RelapseRecoveryScreen({this.logId, super.key});

  final String? logId;

  @override
  ConsumerState<RelapseRecoveryScreen> createState() =>
      _RelapseRecoveryScreenState();
}

class _RelapseRecoveryScreenState extends ConsumerState<RelapseRecoveryScreen> {
  late final Future<SmokingLogRecord?> _logFuture;
  String? _selectedAction;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final logId = widget.logId;
    _logFuture = logId == null
        ? Future.value(null)
        : ref
              .read(smokingLogRepositoryProvider)
              .getById(logId)
              // A missing log should not block the reassurance screen.
              .catchError((Object _) => null);
    ref
        .read(appEventRepositoryProvider)
        .track(
          AppEvent(
            eventName: 'relapse_recovery_opened',
            properties: {'log_id': logId},
          ),
        );
  }

  Future<void> _startRecovery(SmokingLogRecord? log) async {
    if (_started) {
      return;
    }
    setState(() => _started = true);
    try {
      await ref
          .read(appEventRepositoryProvider)
          .track(
            AppEvent(
              eventName: 'relapse_recovery_started',
              properties: {
                'log_id': widget.logId,
                'trigger': log?.trigger,
                'actions': [?_selectedAction],
              },
            ),
          );
    } on Object {
      // Analytics must never block moving on.
    }
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Recovery reset'),
      ),
      body: SafeArea(
        child: FutureBuilder<SmokingLogRecord?>(
          future: _logFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const StateView.loading(label: 'Loading');
            }
            final log = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RecoveryHero(log: log),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Semantics(
                        header: true,
                        child: Text(
                          'What happened?',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Name the pattern once. Then let the next move be small.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _TriggerWrap(trigger: log?.trigger),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Semantics(
                        header: true,
                        child: Text(
                          'Pick one tiny reset',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final action in _actions)
                        SelectableTile(
                          icon: action.icon,
                          title: action.title,
                          subtitle: action.subtitle,
                          selected: _selectedAction == action.id,
                          onTap: () => setState(
                            () => _selectedAction =
                                _selectedAction == action.id ? null : action.id,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      _ResetSummary(log: log),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: _started ? null : () => _startRecovery(log),
                        icon: _started
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  semanticsLabel: 'Starting',
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start recovery'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.logId == null
                                  ? null
                                  : () => context.push(
                                      '${AppRoutes.logging}?logId=${widget.logId}',
                                    ),
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text('Edit log'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.go(AppRoutes.journal),
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: const Text('Journal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResetAction {
  const _ResetAction(this.id, this.icon, this.title, this.subtitle);

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
}

const _actions = [
  _ResetAction(
    'drink_water',
    Icons.water_drop_rounded,
    'Drink water',
    'Give your hands and mouth a clean interruption.',
  ),
  _ResetAction(
    'reset_environment',
    Icons.cleaning_services_rounded,
    'Reset environment',
    'Move the lighter, change rooms, open a window.',
  ),
  _ResetAction(
    'plan_danger_window',
    Icons.schedule_rounded,
    'Plan next danger window',
    'Choose the next risky moment before it chooses you.',
  ),
];

class _RecoveryHero extends StatelessWidget {
  const _RecoveryHero({required this.log});

  final SmokingLogRecord? log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loggedAt = log == null
        ? 'just now'
        : DateFormat.jm().format(log!.smokedAt);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: AppMotion.of(context, AppMotion.emphasized),
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Material(
        color: scheme.secondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: AppShapes.extraLargeIncreased,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: scheme.onSecondaryContainer,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  'Logged. You did not lose everything.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This gives us a clearer map for next time.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Icon(
                    Icons.restart_alt_rounded,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Smoke-free clock restarted from $loggedAt.',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriggerWrap extends StatelessWidget {
  const _TriggerWrap({required this.trigger});

  final String? trigger;

  static const _fallbackTriggers = [
    'stress',
    'bored',
    'social',
    'after food',
    'coffee',
    'routine',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = {
      if (trigger != null && trigger!.isNotEmpty) trigger!,
      ..._fallbackTriggers,
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final chip in chips)
          Chip(
            avatar: chip == trigger
                ? const Icon(Icons.check_rounded, size: 18)
                : null,
            label: Text(toBeginningOfSentenceCase(chip) ?? chip),
            backgroundColor: chip == trigger
                ? scheme.secondaryContainer
                : scheme.surfaceContainerLow,
          ),
      ],
    );
  }
}

class _ResetSummary extends StatelessWidget {
  const _ResetSummary({required this.log});

  final SmokingLogRecord? log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = log?.count ?? 1;

    return AppCard(
      style: AppCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_rounded, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('What changes now', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryLine(
            text:
                'Your smoke-free streak restarts from this $count-cigarette log.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SummaryLine(
            text: 'Your journal kept the truth, so your pattern gets sharper.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SummaryLine(
            text: 'Today is still usable. One reset action is enough.',
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(width: 8, height: 8),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
