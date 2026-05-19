import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../milestone_celebration_controller.dart';

class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({required this.event, super.key});

  final CelebrationEvent event;

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pop;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _pop = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.event;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ..._confetti(event.color),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pop,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: event.color.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Icon(event.icon, size: 50, color: event.color),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _eyebrow(event),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: event.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  event.body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Celebrate this win'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _eyebrow(CelebrationEvent event) {
    return switch (event.kind) {
      CelebrationKind.healthMilestone => 'Health milestone reached',
      CelebrationKind.timeAchievement => 'Achievement unlocked',
    };
  }

  List<Widget> _confetti(Color eventColor) {
    const positions = [
      Offset(18, 10),
      Offset(238, 18),
      Offset(42, 220),
      Offset(260, 190),
      Offset(94, -6),
      Offset(205, 246),
    ];
    final colors = [
      eventColor,
      AppColors.primary,
      AppColors.accentMoney,
      AppColors.accentStreak,
      AppColors.accentCraving,
      eventColor,
    ];

    return [
      for (var i = 0; i < positions.length; i++)
        Positioned(
          left: positions[i].dx,
          top: positions[i].dy,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final drift = math.sin((_controller.value + i) * math.pi) * 5;
              return Transform.translate(
                offset: Offset(0, drift),
                child: child,
              );
            },
            child: _ConfettiPiece(color: colors[i], index: i),
          ),
        ),
    ];
  }
}

class _ConfettiPiece extends StatelessWidget {
  const _ConfettiPiece({required this.color, required this.index});

  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.45 + index * 0.28,
      child: Container(
        width: index.isEven ? 13 : 9,
        height: index.isEven ? 9 : 13,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
