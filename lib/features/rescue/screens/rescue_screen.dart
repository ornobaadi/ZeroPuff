import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/home/providers/home_dashboard_provider.dart';
import '../../../models/app_event.dart';
import '../../../repositories/app_settings_repository.dart';
import '../../../repositories/app_event_repository.dart';
import '../../../repositories/craving_repository.dart';
import '../../../repositories/notification_preferences_repository.dart';
import '../../../repositories/onboarding_repository.dart';
import '../../../services/haptics/haptic_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../models/rescue_phase.dart';

const _rescueReasons = [
  _RescueReason(
    value: 'stress',
    title: 'Stressed',
    subtitle: 'Need a release',
    icon: Icons.bolt_rounded,
  ),
  _RescueReason(
    value: 'bored',
    title: 'Bored',
    subtitle: 'Looking for something to do',
    icon: Icons.hourglass_empty_rounded,
  ),
  _RescueReason(
    value: 'after food',
    title: 'After food',
    subtitle: 'The usual after-meal pull',
    icon: Icons.restaurant_rounded,
  ),
  _RescueReason(
    value: 'coffee',
    title: 'Coffee',
    subtitle: 'Paired with the cup',
    icon: Icons.local_cafe_rounded,
  ),
  _RescueReason(
    value: 'social',
    title: 'Social pressure',
    subtitle: 'Around people smoking',
    icon: Icons.groups_rounded,
  ),
  _RescueReason(
    value: 'routine',
    title: 'Routine',
    subtitle: 'Autopilot habit loop',
    icon: Icons.repeat_rounded,
  ),
  _RescueReason(
    value: 'tired',
    title: 'Tired',
    subtitle: 'Low energy, low patience',
    icon: Icons.bedtime_rounded,
  ),
  _RescueReason(
    value: 'other',
    title: 'Something else',
    subtitle: 'Still worth pausing',
    icon: Icons.more_horiz_rounded,
  ),
];

const _fallbackQuitReason = 'I am choosing the next clean breath.';

enum _RescueStage { setup, active, outcome }

class RescueScreen extends ConsumerStatefulWidget {
  const RescueScreen({super.key});

  @override
  ConsumerState<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends ConsumerState<RescueScreen> {
  int _intensity = 5;
  int _urgeAfter = 5;
  final Set<String> _triggers = {'stress'};
  _RescueStage _stage = _RescueStage.setup;
  RescueProgressState _progress = const RescueProgressState();
  Timer? _timer;
  String? _sessionId;
  String _quitReason = _fallbackQuitReason;

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
            _timer?.cancel();
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
            duration: AppMotion.standard,
            child: switch (_stage) {
              _RescueStage.setup => _SetupView(
                intensity: _intensity,
                triggers: _triggers,
                onIntensityChanged: (value) {
                  _selectionHaptic();
                  setState(() => _intensity = value.round());
                },
                onTriggerToggled: _toggleTrigger,
                onStart: () => _startRescue(),
              ),
              _RescueStage.active => _ActiveView(
                key: const ValueKey('rescue-active'),
                intensity: _intensity,
                progress: _progress,
                quitReason: _quitReason,
                onCompletePhase: _completeCurrentPhase,
              ),
              _RescueStage.outcome => _OutcomeView(
                completedPhaseIds: _progress.completedPhaseIds,
                urgeAfter: _urgeAfter,
                onUrgeChanged: (value) {
                  _selectionHaptic();
                  setState(() => _urgeAfter = value);
                },
                onOutcome: _completeRescue,
              ),
            },
          ),
        ),
      ),
    );
  }

  void _toggleTrigger(String trigger) {
    _selectionHaptic();
    setState(() {
      if (_triggers.contains(trigger) && _triggers.length > 1) {
        _triggers.remove(trigger);
      } else {
        _triggers.add(trigger);
      }
    });
  }

  Future<void> _startRescue() async {
    _timer?.cancel();
    _lightHaptic();
    final repository = ref.read(cravingRepositoryProvider);
    final eventRepository = ref.read(appEventRepositoryProvider);
    final profile = await ref
        .read(onboardingRepositoryProvider)
        .loadCompletedProfile();
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
      _urgeAfter = _intensity;
      _quitReason = _cleanQuitReason(profile?.quitReason);
      _progress = const RescueProgressState();
      _stage = _RescueStage.active;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickRescue());
  }

  void _tickRescue() {
    final next = _progress.tick(intensity: _intensity);
    if (identical(next, _progress)) {
      return;
    }

    final phaseChanged = next.phaseIndex != _progress.phaseIndex;
    final justPaused =
        next.waitingForConfirmation && !_progress.waitingForConfirmation;

    setState(() => _progress = next);

    if (phaseChanged || justPaused) {
      _selectionHaptic();
    }
    if (next.finished) {
      _timer?.cancel();
      _mediumHaptic();
      setState(() => _stage = _RescueStage.outcome);
    }
  }

  Future<void> _completeCurrentPhase() async {
    final phase = _progress.currentPhase;
    _mediumHaptic();
    await ref
        .read(appEventRepositoryProvider)
        .track(
          AppEvent(
            eventName: 'craving_rescue_phase_completed',
            properties: {
              'phase': phase.id,
              'intensity': _intensity,
              'seconds_remaining': _progress.remainingSeconds,
            },
          ),
        );
    if (!mounted) {
      return;
    }

    final next = _progress.completeCurrent(intensity: _intensity);
    final phaseChanged = next.phaseIndex != _progress.phaseIndex;
    setState(() => _progress = next);
    if (phaseChanged) {
      _selectionHaptic();
    }
    if (next.finished) {
      _timer?.cancel();
      setState(() => _stage = _RescueStage.outcome);
    }
  }

  Future<void> _completeRescue(String outcome) async {
    if (outcome == 'resisted') {
      _successHaptic();
    } else {
      _selectionHaptic();
    }

    final sessionId = _sessionId;
    if (sessionId != null) {
      await ref
          .read(cravingRepositoryProvider)
          .completeRescue(sessionId: sessionId, outcome: outcome);
      ref.invalidate(recentCravingsProvider);
    }
    await ref
        .read(appEventRepositoryProvider)
        .track(
          AppEvent(
            eventName: 'craving_outcome_$outcome',
            properties: {
              'urge_after': _urgeAfter,
              'completed_phases': _progress.completedPhaseIds.toList(),
            },
          ),
        );

    if (outcome == 'still_craving') {
      if (mounted) {
        await _startRescue();
      }
      return;
    }

    await _restoreReminders();

    if (mounted) {
      if (outcome == 'smoked') {
        Navigator.of(context).pop();
        GoRouter.of(context).push(AppRoutes.logging);
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

  String _cleanQuitReason(String? value) {
    final reason = value?.trim();
    if (reason == null || reason.isEmpty) {
      return _fallbackQuitReason;
    }
    return reason;
  }

  String _outcomeMessage(String outcome) {
    return switch (outcome) {
      'resisted' => 'Logged. You got through this one.',
      'smoked' => "Logged. Let's keep going.",
      _ => 'Logged. You can restart anytime.',
    };
  }

  bool get _hapticsEnabled => ref.read(hapticsEnabledControllerProvider);

  void _selectionHaptic() {
    HapticService.selection(enabled: _hapticsEnabled);
  }

  void _lightHaptic() {
    HapticService.light(enabled: _hapticsEnabled);
  }

  void _mediumHaptic() {
    HapticService.medium(enabled: _hapticsEnabled);
  }

  void _successHaptic() {
    HapticService.success(enabled: _hapticsEnabled);
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
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      key: const ValueKey('rescue-setup'),
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            128,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceCardDark
                    : theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.08,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.air_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Let us lower the urge first.',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    intensity >= 8
                        ? 'This one feels strong, so the steps will stay concrete.'
                        : 'Name what is pulling you, then follow one small step at a time.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _PhasePreviewRow(),
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
            const SizedBox(height: AppSpacing.xl),
            Text(
              'What is pulling you right now?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pick anything that fits. This is only to make the next two minutes more specific.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReasonSelector(
              selectedValues: triggers,
              onToggled: onTriggerToggled,
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.md,
              AppSpacing.pagePadding,
              AppSpacing.pagePadding,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor.withValues(alpha: 0),
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.94),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.timer_outlined),
              label: const Text('Start two minutes'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({
    super.key,
    required this.intensity,
    required this.progress,
    required this.quitReason,
    required this.onCompletePhase,
  });

  final int intensity;
  final RescueProgressState progress;
  final String quitReason;
  final VoidCallback onCompletePhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = progress.currentPhase;
    final phaseNumber = rescuePhases.indexOf(phase) + 1;
    final minutes = progress.remainingSeconds ~/ 60;
    final seconds = progress.remainingSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final isCompleted = progress.completedPhaseIds.contains(phase.id);
    final requiresConfirmation = phase.requiresConfirmation(intensity);
    final showPrimaryAction =
        progress.waitingForConfirmation ||
        (requiresConfirmation && !isCompleted);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.waitingForConfirmation
                          ? 'Finish this step'
                          : 'Stay with this minute',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Step $phaseNumber of ${rescuePhases.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  '$minutes:$seconds',
                  style: AppTypography.liveCounter.copyWith(
                    fontSize: 40,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PhaseTimeline(progress: progress),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.standard,
              child: _PhaseTaskCard(
                key: ValueKey(phase.id),
                phase: phase,
                progress: progress,
                quitReason: quitReason,
                phaseNumber: phaseNumber,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (showPrimaryAction)
            FilledButton.icon(
              onPressed: onCompletePhase,
              icon: Icon(
                progress.waitingForConfirmation
                    ? Icons.check_circle_rounded
                    : Icons.touch_app_rounded,
              ),
              label: Text(phase.completeLabel),
            )
          else
            OutlinedButton.icon(
              onPressed: isCompleted ? null : onCompletePhase,
              icon: Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.check_rounded,
              ),
              label: Text(isCompleted ? 'Step noted' : phase.completeLabel),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No decision right now. Just finish this window.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasePreviewRow extends StatelessWidget {
  const _PhasePreviewRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: rescuePhases.map((phase) {
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(phase.icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                phase.title.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ReasonSelector extends StatelessWidget {
  const _ReasonSelector({
    required this.selectedValues,
    required this.onToggled,
  });

  final Set<String> selectedValues;
  final ValueChanged<String> onToggled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 420;
        final itemWidth = twoColumn
            ? (constraints.maxWidth - AppSpacing.sm) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _rescueReasons.map((reason) {
            return SizedBox(
              width: itemWidth,
              child: _ReasonCard(
                reason: reason,
                selected: selectedValues.contains(reason.value),
                onTap: () => onToggled(reason.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final _RescueReason reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = selected
        ? AppColors.primaryLight
        : isDark
        ? AppColors.surfaceCardDark
        : AppColors.surfaceElevated;
    final foreground = selected
        ? AppColors.textPrimary
        : theme.colorScheme.onSurface;
    final secondary = selected
        ? AppColors.textSecondary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primaryLight
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.58)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check_rounded : reason.icon,
                color: selected ? AppColors.textPrimary : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    reason.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    reason.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondary,
                      height: 1.2,
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

class _PhaseTimeline extends StatelessWidget {
  const _PhaseTimeline({required this.progress});

  final RescueProgressState progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: rescuePhases.map((phase) {
        final index = rescuePhases.indexOf(phase);
        final isActive = index == progress.phaseIndex;
        final isComplete =
            progress.completedPhaseIds.contains(phase.id) ||
            index < progress.phaseIndex;
        final color = isComplete || isActive
            ? AppColors.primary
            : Theme.of(context).colorScheme.outlineVariant;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == rescuePhases.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              height: isActive ? 10 : 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PhaseTaskCard extends StatelessWidget {
  const _PhaseTaskCard({
    super.key,
    required this.phase,
    required this.progress,
    required this.quitReason,
    required this.phaseNumber,
  });

  final RescuePhase phase;
  final RescueProgressState progress;
  final String quitReason;
  final int phaseNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.surfaceCardDark
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.72);
    final visualColor = isDark
        ? AppColors.surfaceElevatedDark.withValues(alpha: 0.7)
        : AppColors.surfaceCard.withValues(alpha: 0.56);
    final instructionColor = isDark
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.primary.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.navInk.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(phase.icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phase.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      progress.waitingForConfirmation
                          ? 'Ready for your tap'
                          : '${progress.phaseRemainingSeconds}s in this step',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$phaseNumber/${rescuePhases.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: visualColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 184,
                    height: 184,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.055),
                    ),
                  ),
                  switch (phase.id) {
                    'water' => _WaterVisual(progress: progress.phaseProgress),
                    'breathing' => const _BreathingVisual(),
                    'walk' => _WalkVisual(progress: progress.phaseProgress),
                    _ => _ReasonVisual(reason: quitReason),
                  },
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: instructionColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.radio_button_checked_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    phase.id == 'reason' ? quitReason : phase.instruction,
                    style: theme.textTheme.titleMedium?.copyWith(height: 1.25),
                  ),
                ),
              ],
            ),
          ),
          if (progress.waitingForConfirmation) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Confirm this one before we move on.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterVisual extends StatelessWidget {
  const _WaterVisual({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: AppMotion.slow,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          size: const Size(150, 170),
          painter: _WaterGlassPainter(fill: value),
        );
      },
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  const _WaterGlassPainter({required this.fill});

  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final glass = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.24, 8, size.width * 0.52, size.height - 16),
      const Radius.circular(22),
    );
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppColors.primaryDark.withValues(alpha: 0.5);
    final water = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryLight.withValues(alpha: 0.9);
    final waterHeight = (glass.outerRect.height - 14) * fill;
    final waterRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        glass.outerRect.left + 7,
        glass.outerRect.bottom - 7 - waterHeight,
        glass.outerRect.width - 14,
        waterHeight,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(waterRect, water);
    canvas.drawRRect(glass, border);
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primary.withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, glass.outerRect.bottom + 2),
        width: 110 + (20 * fill),
        height: 18,
      ),
      ripple,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterGlassPainter oldDelegate) {
    return oldDelegate.fill != fill;
  }
}

class _BreathingVisual extends StatefulWidget {
  const _BreathingVisual();

  @override
  State<_BreathingVisual> createState() => _BreathingVisualState();
}

class _BreathingVisualState extends State<_BreathingVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value;
        final breathScale = phase < 0.42
            ? 0.72 + (phase / 0.42) * 0.28
            : phase < 0.58
            ? 1.0
            : 1 - ((phase - 0.58) / 0.42) * 0.28;
        final label = phase < 0.42
            ? 'Inhale'
            : phase < 0.58
            ? 'Hold'
            : 'Exhale';

        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: breathScale,
              child: Container(
                width: 154,
                height: 154,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withValues(alpha: 0.65),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
              ),
            ),
            Text(label, style: theme.textTheme.headlineSmall),
          ],
        );
      },
    );
  }
}

class _WalkVisual extends StatelessWidget {
  const _WalkVisual({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0, 1).toDouble();
    return SizedBox(
      width: 210,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: AppMotion.slow,
            curve: Curves.easeOutCubic,
            left: 18.0 + (96.0 * value),
            child: const Icon(
              Icons.directions_walk_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            bottom: 28,
            left: 18,
            right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final active = value >= index / 4;
                return AnimatedContainer(
                  duration: AppMotion.fast,
                  width: active ? 28 : 16,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonVisual extends StatelessWidget {
  const _ReasonVisual({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: AppMotion.slow,
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeView extends StatelessWidget {
  const _OutcomeView({
    required this.completedPhaseIds,
    required this.urgeAfter,
    required this.onUrgeChanged,
    required this.onOutcome,
  });

  final Set<String> completedPhaseIds;
  final int urgeAfter;
  final ValueChanged<int> onUrgeChanged;
  final ValueChanged<String> onOutcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const ValueKey('rescue-outcome'),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Text('Check the urge now', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Text(
          'No shame. Honest data is how the app gets useful.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CompletedPhaseRow(completedPhaseIds: completedPhaseIds),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                'Where is the urge?',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text('$urgeAfter/10', style: theme.textTheme.headlineSmall),
          ],
        ),
        Slider(
          value: urgeAfter.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: urgeAfter.toString(),
          onChanged: (value) => onUrgeChanged(value.round()),
        ),
        const SizedBox(height: AppSpacing.lg),
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
          subtitle: 'Log this round and start another immediately.',
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

class _CompletedPhaseRow extends StatelessWidget {
  const _CompletedPhaseRow({required this.completedPhaseIds});

  final Set<String> completedPhaseIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: rescuePhases.map((phase) {
          final complete = completedPhaseIds.contains(phase.id);
          return Expanded(
            child: Column(
              children: [
                Icon(
                  complete ? Icons.check_circle_rounded : phase.icon,
                  color: complete
                      ? AppColors.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  phase.title.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          );
        }).toList(),
      ),
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

class _RescueReason {
  const _RescueReason({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
}

@Preview(name: 'Active low intensity', group: 'Rescue')
Widget rescueActiveLowIntensityPreview() {
  return _RescuePreviewShell(
    child: _ActiveView(
      intensity: 5,
      progress: const RescueProgressState(phaseIndex: 0),
      quitReason: _fallbackQuitReason,
      onCompletePhase: () {},
    ),
  );
}

@Preview(name: 'Active high intensity checkpoint', group: 'Rescue')
Widget rescueActiveHighIntensityPreview() {
  return _RescuePreviewShell(
    child: _ActiveView(
      intensity: 10,
      progress: const RescueProgressState(
        phaseIndex: 0,
        remainingSeconds: 91,
        phaseRemainingSeconds: 0,
        waitingForConfirmation: true,
      ),
      quitReason: _fallbackQuitReason,
      onCompletePhase: () {},
    ),
  );
}

@Preview(name: 'Breathing phase', group: 'Rescue')
Widget rescueBreathingPhasePreview() {
  return _RescuePreviewShell(
    child: _ActiveView(
      intensity: 6,
      progress: const RescueProgressState(
        phaseIndex: 1,
        remainingSeconds: 80,
        phaseRemainingSeconds: 20,
        completedPhaseIds: {'water'},
      ),
      quitReason: _fallbackQuitReason,
      onCompletePhase: () {},
    ),
  );
}

@Preview(name: 'Outcome', group: 'Rescue')
Widget rescueOutcomePreview() {
  return _RescuePreviewShell(
    child: _OutcomeView(
      completedPhaseIds: rescuePhases.map((phase) => phase.id).toSet(),
      urgeAfter: 3,
      onUrgeChanged: (_) {},
      onOutcome: (_) {},
    ),
  );
}

class _RescuePreviewShell extends StatelessWidget {
  const _RescuePreviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(body: SafeArea(child: child)),
    );
  }
}
