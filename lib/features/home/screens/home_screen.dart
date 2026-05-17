import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ZeroPuff')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Text('Smoke-free', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('0 days', style: AppTypography.displayNumber),
            const SizedBox(height: AppSpacing.xs),
            Text('00:00:00', style: AppTypography.liveCounter),
            const SizedBox(height: AppSpacing.sectionGap),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'The live counter, savings, daily check-in, and streak cards will connect here after the repositories land.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.rescue),
              icon: const Icon(Icons.air_rounded),
              label: const Text("I'm craving"),
            ),
          ],
        ),
      ),
    );
  }
}
