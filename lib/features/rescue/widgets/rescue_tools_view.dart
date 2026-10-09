import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/content_width.dart';
import '../models/rescue_tool.dart';

/// The urge is still strong: offer something different, not the same again.
class RescueToolsView extends StatelessWidget {
  const RescueToolsView({
    required this.toolsUsed,
    required this.onPick,
    required this.onBreatheAgain,
    super.key,
  });

  final List<String> toolsUsed;
  final ValueChanged<String> onPick;
  final VoidCallback onBreatheAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Tools not tried yet come first.
    final tools = [
      ...rescueTools.where((tool) => !toolsUsed.contains(tool.id)),
      ...rescueTools.where((tool) => toolsUsed.contains(tool.id)),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Let us try something else',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Strong urges crest and fall within minutes. Pick one thing to get you over the top.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final tool in tools) ...[
                AppCard(
                  onTap: () => onPick(tool.id),
                  semanticLabel: '${tool.title}. ${tool.subtitle}',
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppSpacing.componentGap,
                          ),
                          child: Icon(
                            tool.icon,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tool.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              tool.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (toolsUsed.contains(tool.id))
                        Icon(
                          Symbols.check_rounded,
                          color: scheme.onSurfaceVariant,
                        )
                      else
                        const Icon(Symbols.chevron_right_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.componentGap),
              ],
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton.icon(
                  onPressed: onBreatheAgain,
                  icon: const Icon(Symbols.air_rounded),
                  label: const Text('Breathe another round'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
