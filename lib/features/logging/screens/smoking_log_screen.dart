import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/content_width.dart';
import '../widgets/slip_form.dart';

/// A full-screen slip form: used to correct a log, and after a rescue that
/// ended in a cigarette. From Home the same form opens as a sheet.
class SmokingLogScreen extends StatelessWidget {
  const SmokingLogScreen({this.logId, super.key});

  final String? logId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = logId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit log' : 'Log a slip')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing
                        ? 'Correct anything that is off. An accurate record is a more useful one.'
                        : 'Private, and quick. Knowing when and why is what stops the next one.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SlipForm(
                    logId: logId,
                    onSaved: (savedId) {
                      if (!isEditing) {
                        context.go('${AppRoutes.recovery}?logId=$savedId');
                        return;
                      }
                      final messenger = ScaffoldMessenger.of(context);
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Log updated.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
