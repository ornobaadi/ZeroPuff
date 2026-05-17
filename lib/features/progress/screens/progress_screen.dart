import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text('Milestones', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Health timeline, savings, and basic achievements will live here for v0.1.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
