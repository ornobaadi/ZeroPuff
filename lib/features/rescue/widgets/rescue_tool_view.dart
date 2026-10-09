import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../../../services/haptics/haptic_service.dart';
import '../models/rescue_tool.dart';
import 'rescue_visuals.dart';

/// One tool in use. Every tool ends the same way: back to checking the urge.
class RescueToolView extends StatelessWidget {
  const RescueToolView({
    required this.tool,
    required this.quitReason,
    required this.hapticsEnabled,
    required this.onDone,
    required this.onBack,
    required this.onStartDelay,
    this.backLabel = 'Other options',
    super.key,
  });

  final RescueTool tool;
  final String quitReason;
  final bool hapticsEnabled;
  final VoidCallback onDone;
  final VoidCallback onBack;
  final String backLabel;

  /// Schedules the ten-minute check-back; returns false if it could not.
  final Future<bool> Function() onStartDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ContentWidth(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Symbols.arrow_back_rounded),
                label: Text(backLabel),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              header: true,
              child: Text(tool.title, style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: switch (tool.id) {
                'grounding' => _GroundingTool(
                  hapticsEnabled: hapticsEnabled,
                  onDone: onDone,
                ),
                'delay' => _DelayTool(onStart: onStartDelay, onDone: onDone),
                'water' => _WaterTool(
                  hapticsEnabled: hapticsEnabled,
                  onDone: onDone,
                ),
                'move' => _ConfirmTool(
                  icon: Symbols.directions_walk_rounded,
                  instruction:
                      'Stand up and go somewhere else: another room, the stairs, outside. The craving is tied to where you are sitting.',
                  doneLabel: 'I moved',
                  onDone: onDone,
                ),
                _ => _ReasonTool(reason: quitReason, onDone: onDone),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolPanel extends StatelessWidget {
  const _ToolPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppShapes.extraLarge,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Center(child: SingleChildScrollView(child: child)),
        ),
      ),
    );
  }
}

class _GroundingStep {
  const _GroundingStep(this.count, this.prompt);

  final int count;
  final String prompt;
}

const _groundingSteps = [
  _GroundingStep(5, 'things you can see'),
  _GroundingStep(4, 'things you can touch'),
  _GroundingStep(3, 'things you can hear'),
  _GroundingStep(2, 'things you can smell'),
  _GroundingStep(1, 'thing you can taste'),
];

/// 5-4-3-2-1: name things around you, tapping once for each.
class _GroundingTool extends StatefulWidget {
  const _GroundingTool({required this.hapticsEnabled, required this.onDone});

  final bool hapticsEnabled;
  final VoidCallback onDone;

  @override
  State<_GroundingTool> createState() => _GroundingToolState();
}

class _GroundingToolState extends State<_GroundingTool> {
  int _step = 0;
  int _found = 0;

  void _tap() {
    final step = _groundingSteps[_step];
    HapticService.tick(enabled: widget.hapticsEnabled);
    if (_found + 1 < step.count) {
      setState(() => _found += 1);
      return;
    }
    if (_step == _groundingSteps.length - 1) {
      HapticService.medium(enabled: widget.hapticsEnabled);
      widget.onDone();
      return;
    }
    setState(() {
      _step += 1;
      _found = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final step = _groundingSteps[_step];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ToolPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Find ${step.count} ${step.prompt}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Look for each one properly, then tap.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ExcludeSemantics(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.componentGap,
                    runSpacing: AppSpacing.componentGap,
                    children: [
                      for (var index = 0; index < step.count; index++)
                        AnimatedContainer(
                          duration: AppMotion.of(context, AppMotion.short),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _found
                                ? scheme.primary
                                : scheme.surface,
                            border: Border.all(color: scheme.primary, width: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: _tap,
          icon: const Icon(Symbols.touch_app_rounded),
          label: Text('Found one (${_found + 1} of ${step.count})'),
        ),
      ],
    );
  }
}

/// A glass that fills one sip at a time.
class _WaterTool extends StatefulWidget {
  const _WaterTool({required this.hapticsEnabled, required this.onDone});

  final bool hapticsEnabled;
  final VoidCallback onDone;

  @override
  State<_WaterTool> createState() => _WaterToolState();
}

class _WaterToolState extends State<_WaterTool> {
  static const _sipsToFinish = 5;
  int _sips = 0;

  void _sip() {
    HapticService.tick(enabled: widget.hapticsEnabled);
    if (_sips + 1 >= _sipsToFinish) {
      HapticService.medium(enabled: widget.hapticsEnabled);
      widget.onDone();
      return;
    }
    setState(() => _sips += 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ToolPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drawn full to empty: the glass drains as the user drinks.
                WaterVisual(progress: 1 - _sips / _sipsToFinish),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Pour a full glass. Drink it slowly, a sip at a time.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: _sip,
          icon: const Icon(Symbols.water_drop_rounded),
          label: Text(_sips + 1 >= _sipsToFinish ? 'Last sip' : 'Took a sip'),
        ),
      ],
    );
  }
}

/// Puts the decision off and asks the app to check back.
class _DelayTool extends StatefulWidget {
  const _DelayTool({required this.onStart, required this.onDone});

  final Future<bool> Function() onStart;
  final VoidCallback onDone;

  @override
  State<_DelayTool> createState() => _DelayToolState();
}

class _DelayToolState extends State<_DelayTool> {
  bool _starting = false;
  bool? _scheduled;

  Future<void> _start() async {
    setState(() => _starting = true);
    final scheduled = await widget.onStart();
    if (mounted) {
      setState(() {
        _starting = false;
        _scheduled = scheduled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final started = _scheduled != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ToolPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  started
                      ? Symbols.hourglass_bottom_rounded
                      : Symbols.hourglass_top_rounded,
                  size: 56,
                  color: scheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    started
                        ? 'Ten minutes, starting now.'
                        : 'You are not saying never. You are saying not for ten minutes.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  switch (_scheduled) {
                    null =>
                      'Most urges fade on their own in that time. Decide again when it is up.',
                    true =>
                      'Do something with your hands. ZeroPuff will check back with you when the time is up.',
                    false =>
                      'Reminders are off, so set a timer yourself. Do something with your hands until it rings.',
                  },
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (started)
          FilledButton.icon(
            onPressed: widget.onDone,
            icon: const Icon(Symbols.check_rounded),
            label: const Text('Okay'),
          )
        else
          FilledButton.icon(
            onPressed: _starting ? null : _start,
            icon: const Icon(Symbols.timer_rounded),
            label: const Text('Start ten minutes'),
          ),
      ],
    );
  }
}

class _ReasonTool extends StatelessWidget {
  const _ReasonTool({required this.reason, required this.onDone});

  final String reason;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ToolPanel(child: ReasonVisual(reason: reason)),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onDone,
          icon: const Icon(Symbols.check_rounded),
          label: const Text('I read it'),
        ),
      ],
    );
  }
}

class _ConfirmTool extends StatelessWidget {
  const _ConfirmTool({
    required this.icon,
    required this.instruction,
    required this.doneLabel,
    required this.onDone,
  });

  final IconData icon;
  final String instruction;
  final String doneLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ToolPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onDone,
          icon: const Icon(Symbols.check_rounded),
          label: Text(doneLabel),
        ),
      ],
    );
  }
}
