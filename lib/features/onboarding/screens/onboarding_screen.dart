import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Set your baseline')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Four calm steps. No pressure.',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Quit date, habit, triggers, and your reason. We will build the full wizard after the data layer is generated.',
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Preview app shell'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
