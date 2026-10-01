import 'package:flutter/material.dart';

import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../milestone_celebration_controller.dart';

/// The one celebratory moment in the app: a badge that pops in, the name of the
/// win, and a single way to dismiss it. Motion is skipped when the system asks
/// for reduced animation.
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
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pop = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = AppAccents.of(context);
    final event = widget.event;
    final isMilestone = event.kind == CelebrationKind.milestone;
    final container = isMilestone
        ? accents.moneyContainer
        : scheme.primaryContainer;
    final onContainer = isMilestone
        ? accents.onMoneyContainer
        : scheme.onPrimaryContainer;
    final eyebrow = isMilestone ? 'Milestone reached' : 'Achievement unlocked';

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pop,
                child: ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: container,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 120,
                      child: event.badgeAsset == null
                          ? Icon(event.icon, size: 56, color: onContainer)
                          : Padding(
                              padding: const EdgeInsets.all(
                                AppSpacing.componentGap,
                              ),
                              child: Image.asset(
                                event.badgeAsset!,
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                eyebrow,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
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
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Celebrate this win'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
