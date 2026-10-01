import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/rolling_number.dart';

/// A live "smoke-free for" clock.
///
/// It owns its own one-second timer, so only this widget rebuilds every second
/// (the rest of the dashboard refreshes once a minute). Screen readers get a
/// label that changes once a minute rather than announcing every tick.
class SmokeFreeTimer extends StatefulWidget {
  const SmokeFreeTimer({required this.since, super.key});

  /// When the current smoke-free period started.
  final DateTime since;

  @override
  State<SmokeFreeTimer> createState() => _SmokeFreeTimerState();
}

class _SmokeFreeTimerState extends State<SmokeFreeTimer> {
  Timer? _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = _computeElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = _computeElapsed());
      }
    });
  }

  @override
  void didUpdateWidget(SmokeFreeTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.since != widget.since) {
      _elapsed = _computeElapsed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _computeElapsed() {
    final elapsed = DateTime.now().difference(widget.since);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final days = _elapsed.inDays;
    final hours = _elapsed.inHours.remainder(24);
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);

    return Semantics(
      label:
          'Smoke-free for $days ${days == 1 ? 'day' : 'days'}, '
          '$hours ${hours == 1 ? 'hour' : 'hours'} and '
          '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: RollingNumber(
                      value: days,
                      countUp: true,
                      style: AppTypography.displayNumber.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  days == 1 ? 'day' : 'days',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TimePill(value: hours, label: 'hours'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimePill(value: minutes, label: 'min'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimePill(value: seconds, label: 'sec'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.componentGap),
        child: Column(
          children: [
            RollingNumber(
              value: value,
              minDigits: 2,
              style: AppTypography.liveCounter.copyWith(
                fontSize: 30,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
