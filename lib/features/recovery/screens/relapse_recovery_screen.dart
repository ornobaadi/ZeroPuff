import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/smoking_log_repository.dart';

class RelapseRecoveryScreen extends ConsumerStatefulWidget {
  const RelapseRecoveryScreen({this.logId, super.key});

  final String? logId;

  @override
  ConsumerState<RelapseRecoveryScreen> createState() =>
      _RelapseRecoveryScreenState();
}

class _RelapseRecoveryScreenState extends ConsumerState<RelapseRecoveryScreen> {
  late final Future<SmokingLogRecord?> _logFuture;
  final Set<String> _selectedActions = {};
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final logId = widget.logId;
    _logFuture = logId == null
        ? Future.value(null)
        : ref.read(smokingLogRepositoryProvider).getById(logId);
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
    await ref
        .read(appEventRepositoryProvider)
        .track(
          AppEvent(
            eventName: 'relapse_recovery_started',
            properties: {
              'log_id': widget.logId,
              'trigger': log?.trigger,
              'actions': _selectedActions.toList(),
            },
          ),
        );
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
              return const Center(child: CircularProgressIndicator());
            }
            final log = snapshot.data;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                const SizedBox(height: AppSpacing.lg),
                _RecoveryHero(log: log),
                const SizedBox(height: AppSpacing.xxl),
                Text('What happened?', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Name the pattern once. Then let the next move be small.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _TriggerWrap(trigger: log?.trigger),
                const SizedBox(height: AppSpacing.xxl),
                Text('Pick one tiny reset', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _RecoveryActionCard(
                  icon: Icons.water_drop_rounded,
                  title: 'Drink water',
                  subtitle: 'Give your hands and mouth a clean interruption.',
                  selected: _selectedActions.contains('drink_water'),
                  onTap: () => _toggleAction('drink_water'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RecoveryActionCard(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Reset environment',
                  subtitle: 'Move the lighter, change rooms, open a window.',
                  selected: _selectedActions.contains('reset_environment'),
                  onTap: () => _toggleAction('reset_environment'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RecoveryActionCard(
                  icon: Icons.schedule_rounded,
                  title: 'Plan next danger window',
                  subtitle:
                      'Choose the next risky moment before it chooses you.',
                  selected: _selectedActions.contains('plan_danger_window'),
                  onTap: () => _toggleAction('plan_danger_window'),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _ResetSummary(log: log),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () => _startRecovery(log),
                  icon: _started
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                const SizedBox(height: AppSpacing.xl),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleAction(String action) {
    setState(() {
      if (!_selectedActions.add(action)) {
        _selectedActions.remove(action);
      }
    });
  }
}

class _RecoveryHero extends StatelessWidget {
  const _RecoveryHero({required this.log});

  final SmokingLogRecord? log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loggedAt = log == null
        ? 'Just now'
        : DateFormat('h:mm a').format(log!.smokedAt);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.relapse.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.relapse.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.relapse.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.relapse,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Logged. You did not lose everything.',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This gives us a clearer map for next time.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(Icons.restart_alt_rounded, color: AppColors.relapse),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Smoke-free clock restarted from $loggedAt.',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ],
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
    final chips = {
      if (trigger != null && trigger!.isNotEmpty) trigger!,
      ..._fallbackTriggers,
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: chips.map((chip) {
        final selected = chip == trigger;
        return Chip(
          avatar: selected
              ? const Icon(Icons.check_rounded, size: 18)
              : const Icon(Icons.circle_outlined, size: 14),
          label: Text(chip),
          backgroundColor: selected
              ? AppColors.relapse.withValues(alpha: 0.16)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          side: BorderSide(
            color: selected
                ? AppColors.relapse.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        );
      }).toList(),
    );
  }
}

class _RecoveryActionCard extends StatelessWidget {
  const _RecoveryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.14)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: selected ? 2 : 1,
            color: selected
                ? AppColors.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.16)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: selected ? AppColors.primary : null),
            ),
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
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: selected ? 1 : 0.8,
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetSummary extends StatelessWidget {
  const _ResetSummary({required this.log});

  final SmokingLogRecord? log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = log?.count ?? 1;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, color: AppColors.primary),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
