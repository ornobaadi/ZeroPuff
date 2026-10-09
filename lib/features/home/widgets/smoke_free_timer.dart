import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/rolling_number.dart';

/// How a stretch of time is laid out on the clock: the largest unit that has
/// started is the big number, and each smaller one gets a tile under it.
/// So the first hour reads "12 minutes" rather than "0 days".
class ClockParts {
  const ClockParts({
    required this.value,
    required this.unit,
    required this.rest,
  });

  factory ClockParts.of(Duration elapsed) {
    final hours = elapsed.inHours.remainder(24);
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    if (elapsed.inDays >= 1) {
      return ClockParts(
        value: elapsed.inDays,
        unit: elapsed.inDays == 1 ? 'day' : 'days',
        rest: [(hours, 'hours'), (minutes, 'min'), (seconds, 'sec')],
      );
    }
    if (elapsed.inHours >= 1) {
      return ClockParts(
        value: hours,
        unit: hours == 1 ? 'hour' : 'hours',
        rest: [(minutes, 'min'), (seconds, 'sec')],
      );
    }
    return ClockParts(
      value: minutes,
      unit: minutes == 1 ? 'minute' : 'minutes',
      rest: [(seconds, 'sec')],
    );
  }

  final int value;
  final String unit;

  /// The smaller units, largest first, each with its short label.
  final List<(int, String)> rest;
}

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
    final color = theme.colorScheme.onPrimaryContainer;

    final days = _elapsed.inDays;
    final hours = _elapsed.inHours.remainder(24);
    final minutes = _elapsed.inMinutes.remainder(60);
    final parts = ClockParts.of(_elapsed);

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
                      // A new unit taking over starts its own count.
                      key: ValueKey(parts.rest.length),
                      value: parts.value,
                      countUp: true,
                      style: AppTypography.displayNumber.copyWith(color: color),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  parts.unit,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (final (index, (value, unit)) in parts.rest.indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TimeTile(
                      key: ValueKey(unit),
                      value: value,
                      label: unit,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One smaller unit of the clock in its own box, so the digits stay on a
/// grid while they roll.
class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.value, required this.label, super.key});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        borderRadius: AppShapes.largeIncreased,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.componentGap),
        child: Column(
          children: [
            RollingNumber(
              value: value,
              minDigits: 2,
              style: AppTypography.liveCounter.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label.toUpperCase(),
              style: AppTypography.liveCounterLabel.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
