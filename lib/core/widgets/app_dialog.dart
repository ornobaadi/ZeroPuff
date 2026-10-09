import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The one dialog layout in the app: a title, a short message or custom
/// content, and two buttons of equal width side by side.
///
/// The app's filled buttons are full width by design, which makes the stock
/// [AlertDialog] stack its actions unevenly; this keeps them level.
class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.primaryLabel,
    required this.onPrimary,
    this.message,
    this.content,
    this.icon,
    this.secondaryLabel = 'Cancel',
    this.onSecondary,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String? message;

  /// Shown under the message, for dialogs that collect something.
  final Widget? content;
  final IconData? icon;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;

  /// Defaults to closing the dialog.
  final VoidCallback? onSecondary;

  /// Colors the primary button and icon as a warning.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = this.message;
    final content = this.content;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 28,
                color: destructive ? scheme.error : scheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.headlineSmall),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.md),
              content,
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary ?? () => Navigator.of(context).pop(),
                    child: Text(secondaryLabel, textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    style: destructive
                        ? FilledButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                          )
                        : null,
                    onPressed: onPrimary,
                    child: Text(primaryLabel, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
