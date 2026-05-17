import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class RescueScreen extends StatelessWidget {
  const RescueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Two-minute rescue')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Give me two minutes before you decide.',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'This flow will become the offline craving rescue: intensity, trigger chips, timed micro-actions, and outcome logging.',
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
