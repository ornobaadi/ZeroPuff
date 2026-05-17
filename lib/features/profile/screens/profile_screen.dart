import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text('Your setup', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Profile, notification preferences, sign out, and account deletion will be built after auth and local persistence are wired.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
